import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:the_namur_frontend/Widgets/drawer_menu.dart';

import '../provider/machine_provider.dart';
import '../utils/colors.dart';
import '../widgets/info_chip.dart';

class MachineInfoScreen extends StatelessWidget {
  const MachineInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final machine = Provider.of<MachineProvider>(context).machine;

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Man Machines",
        showBack: true, // set false if you don’t want back button
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  machine.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _buildTopIcon(
                        'assets/images/share.png',
                        onTap: () {
                          // share logic here
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildTopIcon(
                        'assets/images/comment.png',
                        onTap: () {
                          // comment logic here
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildTopIcon(
                        'assets/images/like.png',
                        onTap: () {
                          // like logic here
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${machine.name} ${machine.model} - ${machine.price} Lac",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      InfoChip(
                        label: "Running Hrs",
                        value: "250 Hrs",
                        color: AppColors.pink,
                      ),
                      SizedBox(width: 10),
                      InfoChip(
                        label: "Rating",
                        value: "⭐⭐⭐⭐⭐ 5",
                        color: AppColors.yellow,
                      ),
                      SizedBox(width: 10),
                      InfoChip(
                        label: "Kms",
                        value: "40000kms",
                        color: AppColors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2F02_JCB.png?alt=media&token=c90db698-f547-47fa-b226-ee4866849b7e',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              machine.ownerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(machine.vehicleNo),
                          ],
                        ),
                        const Spacer(),
                        Image.asset('assets/images/whatsapp.png', height: 35),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    color: AppColors.greyBox,
                    child: const Text(
                      "1. Price - 35.5 Lakhs\n2. Mileage Good: 15km/Ltr\n3. Diesel: 3ltr/hr\n4. Consistent Track Record\n5. Linked To Namur\n6. Adapts To Farmers Requirement",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        minimumSize: const Size(200, 45),
                      ),
                      onPressed: () {
                        _showBookingDialog(context);
                      },
                      child: const Text(
                        "Book",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _optionTile(String image, String text) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      //color: AppColors.greyBox,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Image.asset(image, height: 50),
        const SizedBox(width: 8),
        Container(
          height: 70,
          width: 250,
          decoration: BoxDecoration(
            color: Color.fromRGBO(243, 13, 13, 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(text)),
        ),
      ],
    ),
  );
}

void _showBookingDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Close",
    barrierColor: Colors.black.withOpacity(0.4), // transparent background
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _bookingContent(context),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

Widget _bookingContent(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 10),
      const Text(
        "Enter Details",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.greyBox,
        ),
        child: Column(
          children: [
            _optionTile('assets/images/calender_day.png', "Select Date"),
            _optionTile('assets/images/watch.png', "Select Time"),
            _optionTile('assets/images/field.png', "Select Farm / Location"),
          ],
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade700,
          minimumSize: const Size(200, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          "Preview & Book",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

// 🔸 Custom widget for top-right icons
Widget _buildTopIcon(String assetPath, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Image.asset(assetPath, height: 20, width: 20),
    ),
  );
}
