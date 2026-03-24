import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/drawer_menu.dart';
import '../Widgets/profile_header.dart';

class ProfileCardScreen extends StatelessWidget {
  const ProfileCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const DrawerMenu(),
      body: Column(
        children: [
          // ---------- HEADER IMAGE ----------
          ProfileHeader(
            name: "Chiranthana",
            location: "Pitlali - 577511",
            friends: '${125} ${'friends_and_neighbors'.tr()}',
            isbarcode: true,
            imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2Fmore%2Ffarmers.png?alt=media&token=663f050d-24b2-43c5-9196-b43800a5a725',
          ),

          // ---------- PROFILE CARD ----------
        ],
      ),
    );
  }
}
