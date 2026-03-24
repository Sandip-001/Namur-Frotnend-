import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_namur_frontend/Widgets/booking_ad_card.dart';

import '../provider/my_booking_provider.dart';
import 'machinery_description_screen.dart';
import '../Widgets/custom_appbar.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late bool isRent;
  bool _adsLoaded = false;

  @override
  void initState() {
    print('all machinery product');
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adsLoaded) {
      _adsLoaded = true;
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid");

    if (userId == null) return;

    final provider = Provider.of<MyBookingsProvider>(context, listen: false);

    await provider.fetchMyBookings(userId);
  }

  void _refreshAds() async {
    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyBookingsProvider>(context);
    final bookings = provider.bookings;

    return Scaffold(
      appBar: CustomAppBar(title: "My Bookings", showBack: true),
      backgroundColor: Colors.white,
      // Floating button logic same as old
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookings.isEmpty
                ? const Center(child: Text("No bookings found"))
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (_, i) {
                      final booking = bookings[i];

                      return BookingAdCard(
                        ad: booking, // 🔥 reuse same card

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MachineryDescriptionScreen(
                                ad: booking.ad,
                                isBooking: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
