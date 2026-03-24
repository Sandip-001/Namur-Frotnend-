import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../Widgets/custom_appbar.dart';
import '../provider/crop_selection_provider.dart';
import '../provider/land_provider.dart';
import '../utils/my_theme.dart';
import 'crop_selection_screen.dart';
import 'edit_profile_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'calendar'.tr(), showBack: true),
      body: _bodyScreen(),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final landProvider = Provider.of<LandDetailsProvider>(
        context,
        listen: false,
      );
      final cropProvider = Provider.of<CropSelectionProvider>(
        context,
        listen: false,
      );

      // 1️⃣ Ensure lands are loaded
      if (landProvider.lands.isEmpty) {
        await landProvider.fetchLandsByUser();
      }

      // 2️⃣ Fetch crops for first land
      if (landProvider.lands.isNotEmpty) {
        final landId = landProvider.lands.first.id;
        await cropProvider.fetchCropList(landId: landId);
      }
    });
  }

  Widget _bodyScreen() {
    return Consumer2<LandDetailsProvider, CropSelectionProvider>(
      builder: (context, landProvider, cropProvider, _) {
        final hasLand = landProvider.lands.isNotEmpty;
        final hasCrop = cropProvider.cropList.isNotEmpty;

        String buttonText;
        VoidCallback onPressed;

        if (!hasLand) {
          buttonText = 'add_land'.tr();
          onPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          };
        } else if (!hasCrop) {
          buttonText = 'add_crop'.tr();
          onPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          };
        } else {
          buttonText = 'add_crop_tracking'.tr();
          onPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CropSelectionScreen()),
            );
          };
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                !hasLand
                    ? 'no_land_found'.tr()
                    : !hasCrop
                    ? 'no_crop_found'.tr()
                    : 'no_crop_tracking'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .5,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 13,
                    color: MyTheme.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
