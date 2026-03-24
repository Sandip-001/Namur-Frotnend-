import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/screens/more_details_screen.dart';

import '../provider/user_provider.dart';
import '../services/profile_service.dart';

class ProfileHeader extends StatefulWidget {
  final String name;
  final String location;
  final String friends;
  final String imageUrl;
  final bool isbarcode;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.location,
    required this.friends,
    required this.imageUrl,
    required this.isbarcode,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  /// 📌 Pick image → upload immediately
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (picked != null) {
                  setState(() => _pickedImage = File(picked.path));
                  _uploadProfileImage();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  setState(() => _pickedImage = File(picked.path));
                  _uploadProfileImage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Upload image → update provider → show snackbar
  Future<void> _uploadProfileImage() async {
    if (_pickedImage == null) return;

    final result = await ProfileService().uploadProfileImage(_pickedImage!);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload failed"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Parse API response directly
    final msg = result["message"];
    final newUrl = result["user"]["profile_image_url"];

    // Update provider
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).updateProfileImage(newUrl);

    // Clear picked image so network image shows again
    setState(() {
      _pickedImage = null;
    });

    // Show success msg
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Provider image if updated, else old widget URL
    final imageToShow = userProvider.user?.profileImageUrl ?? widget.imageUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔹 Background image (UNCHANGED UI)
        ClipRRect(
          child: _pickedImage != null
              ? Image.file(
                  _pickedImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imageToShow,
                  width: double.infinity,
                  height: double.infinity, // 🔥 Fills full flexible space
                  fit: BoxFit.cover,
                ),
        ),

        // 🔹 Drawer icon (UNCHANGED)
        Positioned(
          top: 40,
          left: 15,
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 22),
            ),
          ),
        ),

        // 🔹 Settings icon (UNCHANGED)
        Positioned(
          top: 40,
          right: 15,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MoreDetailsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 22),
            ),
          ),
        ),

        // 🔹 Edit icon (UNCHANGED)
        Positioned(
          bottom: 10,
          right: 15,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
