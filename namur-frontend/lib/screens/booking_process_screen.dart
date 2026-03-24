import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_range_picker/time_range_picker.dart';
import '../utils/colors.dart';

class BookingProcessDialog extends StatefulWidget {
  final String userId;
  final String adId;

  const BookingProcessDialog({
    super.key,
    required this.userId,
    required this.adId,
  });

  @override
  State<BookingProcessDialog> createState() => _BookingProcessDialogState();
}

class _BookingProcessDialogState extends State<BookingProcessDialog> {
  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  List<String> timeSlots = [];
  String? selectedFarm; // UI display
  int? selectedLandId; // 🔥 actual ID
  List<String> bookedSlotLabels = [];
  bool isSlotLoading = false;
  List<Map<String, dynamic>> farmList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFarms();
    generateTimeSlots();
  }

  void generateTimeSlots() {
    timeSlots.clear();
    for (int hour = 6; hour < 21; hour += 3) {
      final from = TimeOfDay(hour: hour, minute: 0);
      final to = TimeOfDay(hour: hour + 3, minute: 0);
      timeSlots.add("${formatTime(from)} - ${formatTime(to)}");
    }
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> pickTime() async {
    final result = await showTimeRangePicker(
      context: context,
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 0),
      minDuration: const Duration(hours: 3),
      interval: const Duration(hours: 1),
      labelStyle: const TextStyle(
        color: Colors.black, // ⬅ clock numbers
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      timeTextStyle: const TextStyle(
        color: Colors.black, // ⬅ top From–To time
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      use24HourFormat: false,
      ticks: 24,
      strokeWidth: 8,
      ticksColor: Colors.grey,
      ticksLength: 12,
      ticksOffset: -7,

      // ✅ FIX: ClockLabel instead of String
      labels: [
        ClockLabel.fromIndex(idx: 0, length: 24, text: "12 am"),
        ClockLabel.fromIndex(idx: 3, length: 24, text: "3 am"),
        ClockLabel.fromIndex(idx: 6, length: 24, text: "6 am"),
        ClockLabel.fromIndex(idx: 9, length: 24, text: "9 am"),
        ClockLabel.fromIndex(idx: 12, length: 24, text: "12 pm"),
        ClockLabel.fromIndex(idx: 15, length: 24, text: "3 pm"),
        ClockLabel.fromIndex(idx: 18, length: 24, text: "6 pm"),
        ClockLabel.fromIndex(idx: 21, length: 24, text: "9 pm"),
      ],

      rotateLabels: false,
      fromText: "From",
      toText: "To",
      backgroundColor: Colors.white,
      handlerColor: Colors.green,
      selectedColor: Colors.green,

      snap: true,
    );

    if (result != null) {
      setState(() {
        fromTime = result.startTime;
        toTime = result.endTime;
      });
    }
  }

  /// ---------------- DATE ----------------
  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        bookedSlotLabels.clear(); // clear previous date slots
      });

      // 🔥 CALL API WITH SELECTED DATE
      await fetchBookedSlots(picked);
    }
  }

  String formatApiTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // produces: 10 am, 1 pm
    return DateFormat('h a').format(dt).toLowerCase();
  }

  /// ---------------- TIME ----------------
  /*  Future<void> pickTime() async {
    final result = await showTimeRangePicker(
      context: context,
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 0),
      minDuration: const Duration(hours: 3),
      interval: const Duration(hours: 1),
      use24HourFormat: false,
      backgroundColor: Colors.white,
      handlerColor: Colors.green,
      selectedColor: Colors.green,
    );

    if (result != null) {
      setState(() {
        fromTime = result.startTime;
        toTime = result.endTime;
      });
    }
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }*/

  /// ---------------- FETCH FARMS ----------------
  Future<void> fetchFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid");

    final url = Uri.parse('https://api.inkaanalysis.com/api/land/user/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          farmList = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
  }

  /// ---------------- BOOKING ----------------
  Future<void> submitBooking() async {
    if (selectedDate == null ||
        fromTime == null ||
        toTime == null ||
        selectedLandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all details"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "ad_id": widget.adId,
      "booked_by_user_id": widget.userId,
      "land_id": selectedLandId,
      "booking_date": DateFormat('yyyy-MM-dd').format(selectedDate!),
      "start_time": formatApiTime(fromTime!), // 10 am
      "end_time": formatApiTime(toTime!), // 1 pm
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.inkaanalysis.com/api/book-ads'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      // close dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        // ✅ SUCCESS
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking confirmed"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        Navigator.pop(context, false);
        // ❌ FAILURE — show backend message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData["message"] ?? "Booking failed"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchBookedSlots(DateTime date) async {
    setState(() => isSlotLoading = true);

    final formattedDate = DateFormat('dd-MM-yyyy').format(date);

    final url = Uri.parse(
      'https://api.inkaanalysis.com/api/book-ads/booked-slots/${widget.adId}/$formattedDate',
    );
    print(url);

    try {
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List slots = decoded['slots'] ?? [];

        setState(() {
          bookedSlotLabels = slots.map((e) => e['label'].toString()).toList();
        });
      } else {
        bookedSlotLabels = [];
      }
    } catch (e) {
      bookedSlotLabels = [];
    }

    setState(() => isSlotLoading = false);
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'booking_process'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text('enter_details'.tr(), style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),

              _optionTile(
                'assets/images/calender_day.png',
                selectedDate != null
                    ? DateFormat.yMMMEd().format(selectedDate!)
                    : 'select_date'.tr(),
                onTap: pickDate,
              ),

              if (selectedDate != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Already Booked Slots",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (isSlotLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (bookedSlotLabels.isEmpty)
                        const Text(
                          "No slot booked yet",
                          style: TextStyle(color: Colors.black54),
                        )
                      else
                        Column(
                          children: bookedSlotLabels.map((slot) {
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.block,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    slot,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

              _optionTile(
                'assets/images/watch.png',
                fromTime != null && toTime != null
                    ? "${formatTime(fromTime!)} - ${formatTime(toTime!)}"
                    : 'select_time'.tr(),
                onTap: pickTime,
              ),

              _optionTile(
                'assets/images/field.png',
                selectedFarm ?? 'select_farm'.tr(),
                isDropdown: true,
                dropdownItems: farmList
                    .map((e) => e["land_name"].toString())
                    .toList(),
                onDropdownChanged: (val) {
                  final farm = farmList.firstWhere(
                    (e) => e["land_name"] == val,
                  );
                  setState(() {
                    selectedFarm = val;
                    selectedLandId = farm["id"]; // ✅ FIX
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : submitBooking,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'preview_and_book'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- OPTION TILE (UNCHANGED UI) ----------------
  Widget _optionTile(
    String image,
    String text, {
    VoidCallback? onTap,
    bool isDropdown = false,
    List<String>? dropdownItems,
    ValueChanged<String>? onDropdownChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.greyBox,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(image, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: isDropdown
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(243, 13, 13, 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: selectedFarm,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: Center(child: Text(text)),
                      items: dropdownItems
                          ?.map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Center(child: Text(e)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null && onDropdownChanged != null) {
                          onDropdownChanged(val);
                        }
                      },
                    ),
                  )
                : GestureDetector(
                    onTap: onTap,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(243, 13, 13, 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(text)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
