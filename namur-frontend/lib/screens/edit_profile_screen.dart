import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:the_namur_frontend/Widgets/drawer_menu.dart';
import 'package:the_namur_frontend/provider/district_provider.dart';
import 'package:the_namur_frontend/provider/edit_profile_provider.dart';
import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_textfield.dart';
import '../Widgets/product_dropdown.dart';
import '../provider/details_provider.dart';

import '../provider/land_district_provider.dart';
import '../provider/land_product_list_provider.dart';
import '../provider/land_product_provider.dart';
import '../provider/land_provider.dart';
import '../provider/product_provider_api.dart';
import '../provider/user_provider.dart';
import '../services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/string_extension.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();
  final acresController = TextEditingController();
  final modelController = TextEditingController();
  final regController = TextEditingController();
  final chassiController = TextEditingController();
  final rcCopyController = TextEditingController();
  final quantityController = TextEditingController();
  late TextEditingController mobileController;
  late TextEditingController nameController;
  final TextEditingController _nameController = TextEditingController();

  String _originalName = "";
  bool _showSaveButton = false;
  bool _isSaving = false;
  bool isEditingAddress = false;
  @override
  void initState() {
    super.initState();
    resetAllFields();

    //Provider.of<DistrictProvider>(context, listen: false).loadDistricts();
    final p = Provider.of<ProductProvider>(context, listen: false);
    Provider.of<LandProductProvider>(context, listen: false).resetAll();
    p.fetchProductsByCategory("food");
    p.fetchProductsByCategory("machinery");
    p.fetchProductsByCategory("animal");
    Provider.of<LandDistrictProvider>(context, listen: false).loadDistricts();

    final user = context.read<UserProvider>().user;
    _originalName = user?.username ?? "";
    _nameController.text = _originalName;

    _nameController.addListener(_onNameChanged);
    mobileController = TextEditingController(text: user?.mobile ?? "");
    nameController = TextEditingController(text: user?.username ?? "");
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString("firebase_uid");

      // ✅ EXPLICIT SUCCESS CHECK
      final success = await context.read<UserProvider>().updateExtra(
        body: {"firebase_uid": uid, "username": newName},
      );

      if (!success) throw Exception("API failed");

      // ✅ Save ONLY after API success
      await prefs.setString("username", newName);

      _originalName = newName;

      if (!mounted) return;

      setState(() {
        _showSaveButton = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name updated successfully"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update name")));
    }
  }

  Widget _infoRow(String label, String? value, [Color? color]) {
    final Color textColor = color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for labels to ensure alignment
            child: Text(
              "$label: ",
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          Expanded(
            child: Text(value ?? "-", style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  void _onNameChanged() {
    final currentText = _nameController.text.trim();

    if (currentText != _originalName) {
      if (!_showSaveButton) {
        setState(() => _showSaveButton = true);
      }
    } else {
      if (_showSaveButton) {
        setState(() => _showSaveButton = false);
      }
    }
  }

  void resetAllFields() {
    // Text controllers
    acresController.clear();
    modelController.clear();
    regController.clear();
    chassiController.clear();
    rcCopyController.clear();
    quantityController.clear();

    // Reset providers
    Provider.of<DistrictProvider>(context, listen: false).resetFields();
    Provider.of<LandDetailsProvider>(context, listen: false).resetFields();
    Provider.of<LandDistrictProvider>(context, listen: false).resetFields();
    /*   Provider.of<ProductProvider>(context, listen: false).resetSelections();
    Provider.of<LandProductProvider>(context, listen: false).resetSelections();*/
  }

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
                  setState(() => _profileImage = File(picked.path));
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
                  setState(() => _profileImage = File(picked.path));
                  _uploadProfileImage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile Picture'),
        content: const Text(
          'Do you want to update your profile with this image?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 🔹 Call your API or save logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    final res = await ProfileService().uploadProfileImage(_profileImage!);

    if (res == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
      return;
    }

    final msg = res["message"];
    final newUrl = res["user"]["profile_image_url"];

    Provider.of<UserProvider>(
      context,
      listen: false,
    ).updateProfileImage(newUrl);

    setState(() => _profileImage = null);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final expand = Provider.of<ProfileProvider>(context);
    final provider = Provider.of<DetailsProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "Edit Profile", showBack: true),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 👇 Profile Image Section
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.user;

                if (user == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- PROFILE IMAGE LEFT ----------------
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (user.profileImageUrl != null
                                                ? NetworkImage(
                                                    user.profileImageUrl!,
                                                  )
                                                : const AssetImage(
                                                    'assets/images/profile_image.png',
                                                  ))
                                            as ImageProvider,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.green,
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 15),

                      // ---------------- NAME & MOBILE RIGHT ----------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mobile (non-editable)
                            CustomTextField(
                              controller: mobileController,
                              hint: "Contact No",
                              readOnly: true,
                            ),
                            const SizedBox(height: 12),

                            // Name
                            CustomTextField(
                              controller: _nameController,
                              hint: "Name",
                            ),
                            if (_showSaveButton)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.22,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                          106,
                                          239,
                                          111,
                                          0.9,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: _isSaving ? null : _saveName,
                                      child: const Text(
                                        "Save",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ---------------- ADDRESS SECTION (unchanged, still uses DistrictProvider) ----------------
            _buildExpandableSection(
              context,
              title: '1. Address',
              expanded: expand.addressExpanded,
              onToggle: () => expand.toggle('address'),
              children: [
                Consumer2<UserProvider, DistrictProvider>(
                  builder: (context, userP, distP, _) {
                    final user = userP.user;
                    if (user == null) return const Text("Loading address...");

                    if (!isEditingAddress) {
                      return GestureDetector(
                        onTap: () async {
                          final landProvider = Provider.of<LandDetailsProvider>(
                            context,
                            listen: false,
                          );
                          final districtProvider =
                              Provider.of<DistrictProvider>(
                                context,
                                listen: false,
                              );

                          if (districtProvider.districts.isEmpty) {
                            await districtProvider.loadDistricts();
                          }

                          districtProvider.setDistrict(
                            user.district!,
                            prefillTaluk: user.taluk,
                            prefillVillage: user.village,
                            prefillPanchayat: user.panchayat,
                          );
                          isEditingAddress = true;

                          expand.landExpanded = true;
                          (context as Element).markNeedsBuild();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow("District", user.district?.toTitleCase()),
                              _infoRow("Taluk", user.taluk?.toTitleCase()),
                              _infoRow("Panchayat", user.panchayat?.toTitleCase()),
                              _infoRow("Village", user.village?.toTitleCase()),
                            ],
                          ),
                        ),
                      );
                    }

                    // EDIT MODE for address (unchanged)
                    return Column(
                      children: [
                        CustomDropdown(
                          hint: 'Select District',
                          items: distP.districts,
                          value: distP.selectedDistrict,
                          onChanged: (val) {
                            distP.setDistrict(val!);
                          },
                          widthFactor: 0.9,
                        ),
                        const SizedBox(height: 10),
                        CustomDropdown(
                          hint: 'Select Taluk',
                          items: distP.taluks,
                          value: distP.selectedTaluk,
                          onChanged: (val) {
                            distP.setTaluk(val!);
                          },
                          widthFactor: 0.9,
                        ),
                        const SizedBox(height: 10),
                        CustomDropdown(
                          hint: 'Select Village',
                          items: distP.villages,
                          value: distP.selectedVillage,
                          onChanged: (val) {
                            distP.setVillage(val!);
                          },
                          widthFactor: 0.9,
                        ),

                        const SizedBox(height: 10),
                        CustomDropdown(
                          hint: 'Select Panchayat',
                          items: distP.panchayats,
                          value: distP.selectedPanchayat,
                          onChanged: (val) {
                            distP.setPanchayat(val!);
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.35,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  106,
                                  239,
                                  111,
                                  0.9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                bool ok = await distP.saveAddressDetails();
                                if (ok) {
                                  await userP.fetchProfile();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Address updated successfully",
                                      ),
                                    ),
                                  );
                                  isEditingAddress = false;
                                  (context as Element).markNeedsBuild();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Failed to update address"),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            // ---------------- LAND DETAILS ----------------
            _buildExpandableSection(
              context,
              title: '2. Land Details',
              expanded: expand.landExpanded,
              onToggle: () => expand.toggle('land'),
              children: [
                // ---------------- LAND LIST ----------------
                Consumer2<LandDetailsProvider, LandDistrictProvider>(
                  builder: (context, landP, landDistrictP, _) {
                    if (landP.isLoadingList) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (landP.lands.isEmpty) {
                      return const Text("No land added yet.");
                    }

                    return Column(
                      children: landP.lands.map((land) {
                        final bool isSelected = landP.selectedLandId == land.id;

                        final Color textColor = isSelected
                            ? Colors.white
                            : Colors.black;
                        final Color subTextColor = isSelected
                            ? Colors.white70
                            : Colors.grey.shade700;

                        return GestureDetector(
                          onTap: () async {
                            if (landDistrictP.districts.isEmpty) {
                              await landDistrictP.loadDistricts();
                            }

                            landP.selectLand(land);

                            landP.farmNameController.text = land.landName;
                            landP.surveyNoController.text = land.surveyNo;
                            landP.hissaNoController.text = land.hissaNo;
                            landP.farmSizeController.text = land.farmSize
                                .toString();

                            landDistrictP.setDistrict(
                              land.district,
                              prefillTaluk: land.taluk,
                              prefillVillage: land.village,
                              prefillPanchayat: land.panchayat,
                            );
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors
                                        .green
                                        .shade700 // ✅ FULL GREEN
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade700,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        land.landName.isEmpty ? "Farm" : land.landName.toTitleCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      _infoRow(
                                        "District",
                                        land.district.toTitleCase(),
                                        subTextColor,
                                      ),
                                      _infoRow(
                                        "Taluk",
                                        land.taluk.toTitleCase(),
                                        subTextColor,
                                      ),
                                      _infoRow(
                                        "Village",
                                        land.village.toTitleCase(),
                                        subTextColor,
                                      ),
                                      _infoRow(
                                        "Panchayat",
                                        land.panchayat.toTitleCase(),
                                        subTextColor,
                                      ),
                                      _infoRow(
                                        "Survey No",
                                        land.surveyNo,
                                        subTextColor,
                                      ),
                                      _infoRow(
                                        "Hissa No",
                                        land.hissaNo,
                                        subTextColor,
                                      ),
                                      _infoRow(
                                        "Size",
                                        "${land.farmSize} Acres",
                                        subTextColor,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("Confirm Delete"),
                                            content: const Text(
                                              "Are you sure you want to delete this land?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                                child: const Text("No"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text("Yes"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          final ok = await landP.deleteLand(
                                            land.id,
                                          );
                                          if (ok) {
                                            await landP.fetchLandsByUser();
                                          }

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                ok
                                                    ? "Deleted"
                                                    : "Delete failed",
                                              ),
                                            ),
                                          );
                                        }
                                      },

                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: isSelected
                                            ? Colors.white
                                            : Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // ---------------- LAND FORM ----------------
                Consumer2<LandDetailsProvider, LandDistrictProvider>(
                  builder: (context, landP, landDistrictP, _) {
                    final isEditing = landP.selectedLandId != null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          hint: 'Enter Your Farm Name',
                          controller: landP.farmNameController,
                        ),
                        const SizedBox(height: 10),

                        // District Dropdown
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: CustomDropdown(
                            hint: 'Select District',
                            items: landDistrictP.districts,
                            value: landDistrictP.selectedDistrict,
                            onChanged: (val) {
                              if (val != null) landDistrictP.setDistrict(val);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Taluk Dropdown
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: CustomDropdown(
                            hint: 'Select Taluk',
                            items: landDistrictP.taluks,
                            value: landDistrictP.selectedTaluk,
                            onChanged: (val) {
                              if (val != null) landDistrictP.setTaluk(val);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Village Dropdown
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: CustomDropdown(
                            hint: 'Select Village',
                            items: landDistrictP.villages,
                            value: landDistrictP.selectedVillage,
                            onChanged: (val) {
                              if (val != null) landDistrictP.setVillage(val);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Panchayat Dropdown
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: CustomDropdown(
                            hint: 'Select Panchayat',
                            items: landDistrictP.panchayats,
                            value: landDistrictP.selectedPanchayat,
                            onChanged: (val) {
                              if (val != null) landDistrictP.setPanchayat(val);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Survey & Hissa
                        CustomTextField(
                          hint: 'Enter Survey No',
                          controller: landP.surveyNoController,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hint: 'Enter Hissa No',
                          controller: landP.hissaNoController,
                        ),
                        const SizedBox(height: 10),

                        // Farm Size & Save Button
                        CustomTextField(
                          hint: 'Enter Farm Size (Acres)',
                          controller: landP.farmSizeController,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.35,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  106,
                                  239,
                                  111,
                                  0.9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: landP.isSaving
                                  ? null
                                  : () async {
                                      if (landP.farmNameController.text
                                              .trim()
                                              .isEmpty ||
                                          landDistrictP.selectedDistrict ==
                                              null ||
                                          landDistrictP.selectedTaluk == null ||
                                          landDistrictP.selectedVillage ==
                                              null ||
                                          landDistrictP.selectedPanchayat ==
                                              null ||
                                          landP.surveyNoController.text
                                              .trim()
                                              .isEmpty ||
                                          landP.hissaNoController.text
                                              .trim()
                                              .isEmpty ||
                                          landP.farmSizeController.text
                                              .trim()
                                              .isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "All fields required",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      bool ok;
                                      if (isEditing) {
                                        ok = await landP.updateLand(
                                          landP.selectedLandId!,
                                          landDistrictP.selectedPanchayat,
                                        );
                                      } else {
                                        ok = await landP.saveLandDetails(
                                          district:
                                              landDistrictP.selectedDistrict!,
                                          taluk: landDistrictP.selectedTaluk!,
                                          village:
                                              landDistrictP.selectedVillage!,
                                          panchayat:
                                              landDistrictP.selectedPanchayat ??
                                              "",
                                        );
                                      }

                                      if (ok) {
                                        await landP.fetchLandsByUser();

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEditing
                                                  ? "Land updated!"
                                                  : "Land details saved!",
                                            ),
                                          ),
                                        );

                                        landP.resetFields();
                                        landDistrictP.resetFields();
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              landP.errorMessage ??
                                                  "Failed to save land",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              child: landP.isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : const Text(
                                      'Save',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),

            // ---------------- GLOBAL LAND DROPDOWN ----------------
            _buildExpandableSection(
              context,
              title: '3. Crop Details',
              expanded: expand.cropExpanded,
              onToggle: () => expand.toggle('crop'),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔵 TOPIC TITLE BAR
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        bottom: 0,
                        top: 10,
                      ),
                      child: Text(
                        "Select Land for Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // 🔽 GLOBAL LAND DROPDOWN (unchanged)
                    LandDropdown(
                      hint: "Select Land",
                      onSelected: (landId) {
                        final landP = Provider.of<LandDetailsProvider>(
                          context,
                          listen: false,
                        );
                        final selectedLand = landP.lands.firstWhere(
                          (e) => e.id == landId,
                        );

                        // select land
                        landP.selectLand(selectedLand);

                        // Fetch all 3 category lists
                        final lp = Provider.of<LandProductProvider>(
                          context,
                          listen: false,
                        );
                        lp.selectedLandId = landId;
                        lp.fetchLandProducts(landId: landId);
                      },
                    ),

                    const SizedBox(height: 10),
                  ],
                ),

                // ---------------- EXISTING ADDED CROPS ----------------
                Consumer<LandProductProvider>(
                  builder: (context, lp, _) {
                    if (lp.isLoadingFor('food')) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = lp.getItems('food');
                    if (items.isEmpty) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items.map((m) {
                          final productName = m['product_name'] ?? "Unknown";
                          final acres = m['acres'];
                          final id =
                              m['id']; // Make sure ID included in API response
                          final category =
                              m['category']; // Also include category in response

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// ---- Product Name (Acres) text ----
                                Text(
                                  acres != null
                                      ? "$productName ($acres)"
                                      : productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(width: 6),

                                /// ---- X delete icon ----
                                GestureDetector(
                                  onTap: () async {
                                    final provider =
                                        Provider.of<LandProductListProvider>(
                                          context,
                                          listen: false,
                                        );

                                    bool ok = await provider.deleteLandProduct(
                                      id,
                                    );

                                    if (!context.mounted) return; // ✅ REQUIRED

                                    if (ok) {
                                      // 1. Refresh main list
                                      final lp =
                                          Provider.of<LandProductProvider>(
                                            context,
                                            listen: false,
                                          );
                                      lp.fetchLandProducts(
                                        landId: lp.selectedLandId!,
                                      );

                                      // 2. Refresh category list
                                      provider.fetchLandProductsByCategory(
                                        category,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Deleted successfully"),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Delete failed!"),
                                        ),
                                      );
                                    }
                                  },

                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ---------------- PRODUCT DROPDOWN ----------------
                ProductDropdown(
                  category: "food",
                  hint: "Select Crop",
                  onSelected: (cropId) {
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).selectCrop(cropId);
                  },
                ),

                const SizedBox(height: 10),

                // ---------------- ACRES INPUT + SAVE ----------------
                CustomTextField(
                  hint: 'Enter Area / Nos',
                  controller: acresController,
                ),
                const SizedBox(height: 12),
                Consumer3<
                  LandDetailsProvider,
                  ProductProvider,
                  LandProductProvider
                >(
                  builder: (context, landP, prodP, landProdP, _) {
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.35,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: landProdP.isSaving
                              ? null
                              : () async {
                                  if (landP.selectedLandId == null ||
                                      prodP.selectedCropId == null ||
                                      acresController.text.isEmpty) {
                                    if (!context.mounted) {
                                      return; // ✅ ADD THIS
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please fill all fields"),
                                      ),
                                    );
                                    return;
                                  }

                                  String? msg = await landProdP.saveLandProduct(
                                    landId: landP.selectedLandId!,
                                    productId: prodP.selectedCropId!,
                                    acres: acresController.text.trim(),
                                  );

                                  if (!context.mounted) return; // ✅ ADD THIS

                                  if (msg != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );

                                    acresController.clear();
                                    prodP.selectedCropId = null;
                                    prodP.notifyListeners();

                                    landProdP.fetchLandProducts(
                                      landId: landP.selectedLandId!,
                                    );
                                  }
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              106,
                              239,
                              111,
                              0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: landProdP.isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            _buildExpandableSection(
              context,
              title: '4. Machinery Details',
              expanded: expand.machineryExpanded,
              onToggle: () => expand.toggle('machinery'),
              children: [
                // ---------------- EXISTING MACHINERY LIST ----------------
                Consumer<LandProductProvider>(
                  builder: (context, lp, _) {
                    if (lp.isLoadingFor('machinery')) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = lp.getItems('machinery');
                    if (items.isEmpty) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items.map((m) {
                          final productName = m['product_name'] ?? "Unknown";
                          final acres = m['acres'];
                          final id =
                              m['id']; // Make sure ID included in API response
                          final category =
                              m['category']; // Also include category in response

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// ---- Product Name (Acres) text ----
                                Text(
                                  acres != null
                                      ? "$productName ($acres)"
                                      : productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(width: 6),

                                /// ---- X delete icon ----
                                GestureDetector(
                                  onTap: () async {
                                    final provider =
                                        Provider.of<LandProductListProvider>(
                                          context,
                                          listen: false,
                                        );

                                    bool ok = await provider.deleteLandProduct(
                                      id,
                                    );

                                    if (ok) {
                                      // 1. Refresh main list under LandProductProvider
                                      final lp =
                                          Provider.of<LandProductProvider>(
                                            context,
                                            listen: false,
                                          );
                                      lp.fetchLandProducts(
                                        landId: lp.selectedLandId!,
                                      );

                                      // 2. Optionally refresh the small category list also
                                      provider.fetchLandProductsByCategory(
                                        category,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Deleted successfully"),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Delete failed!"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // PRODUCT DROPDOWN
                ProductDropdown(
                  category: "machinery",
                  hint: "Select Machinery",
                  onSelected: (id) {
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).selectMachinery(id);
                  },
                ),

                const SizedBox(height: 10),

                CustomTextField(hint: 'Model No', controller: modelController),
                SizedBox(height: 10),
                CustomTextField(hint: 'Reg No', controller: regController),
                SizedBox(height: 10),
                CustomTextField(
                  hint: 'Chassis No',
                  controller: chassiController,
                ),
                SizedBox(height: 10),

                CustomTextField(hint: 'RC Copy', controller: rcCopyController),
                const SizedBox(height: 12),
                Consumer3<
                  LandDetailsProvider,
                  ProductProvider,
                  LandProductProvider
                >(
                  builder: (context, landP, prodP, landProdP, _) {
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.35,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: landProdP.isSaving
                              ? null
                              : () async {
                                  if (landP.selectedLandId == null ||
                                      prodP.selectedMachineryId == null ||
                                      modelController.text.isEmpty ||
                                      regController.text.isEmpty ||
                                      chassiController.text.isEmpty ||
                                      rcCopyController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("All fields required"),
                                      ),
                                    );
                                    return;
                                  }

                                  String? msg = await landProdP.saveMachinery(
                                    landId: landP.selectedLandId!,
                                    productId: prodP.selectedMachineryId!,
                                    modelNo: modelController.text.trim(),
                                    regNo: regController.text.trim(),
                                    chassiNo: chassiController.text.trim(),
                                    rcCopyNo: rcCopyController.text.trim(),
                                  );

                                  if (msg != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );

                                    modelController.clear();
                                    regController.clear();
                                    chassiController.clear();
                                    rcCopyController.clear();
                                    prodP.selectedMachineryId = null;
                                    prodP.notifyListeners();

                                    landProdP.fetchLandProducts(
                                      landId: landP.selectedLandId!,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              106,
                              239,
                              111,
                              0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: landProdP.isSaving
                              ? CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildExpandableSection(
              context,
              title: '5. Sheep, Cow, Chicken',
              expanded: expand.animalsExpanded,
              onToggle: () => expand.toggle('animals'),
              children: [
                // ---------------- EXISTING ADDED ANIMALS ----------------
                Consumer<LandProductProvider>(
                  builder: (context, lp, _) {
                    if (lp.isLoadingFor('animal')) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = lp.getItems('animal');
                    if (items.isEmpty) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items.map((m) {
                          final productName = m['product_name'] ?? "Unknown";
                          final acres = m['acres'];
                          final id =
                              m['id']; // Make sure ID included in API response
                          final category =
                              m['category']; // Also include category in response

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// ---- Product Name (Acres) text ----
                                Text(
                                  acres != null
                                      ? "$productName ($acres)"
                                      : productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(width: 6),

                                /// ---- X delete icon ----
                                GestureDetector(
                                  onTap: () async {
                                    final provider =
                                        Provider.of<LandProductListProvider>(
                                          context,
                                          listen: false,
                                        );

                                    bool ok = await provider.deleteLandProduct(
                                      id,
                                    );

                                    if (ok) {
                                      // 1. Refresh main list under LandProductProvider
                                      final lp =
                                          Provider.of<LandProductProvider>(
                                            context,
                                            listen: false,
                                          );
                                      lp.fetchLandProducts(
                                        landId: lp.selectedLandId!,
                                      );

                                      // 2. Optionally refresh the small category list also
                                      provider.fetchLandProductsByCategory(
                                        category,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Deleted successfully"),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Delete failed!"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                ProductDropdown(
                  category: "animal",
                  hint: "Select Animal",
                  onSelected: (id) {
                    Provider.of<ProductProvider>(
                      context,
                      listen: false,
                    ).selectAnimal(id);
                  },
                ),

                const SizedBox(height: 10),

                CustomTextField(
                  hint: 'Quantity',
                  controller: quantityController,
                ),
                const SizedBox(height: 12),
                Consumer3<
                  LandDetailsProvider,
                  ProductProvider,
                  LandProductProvider
                >(
                  builder: (context, landP, prodP, landProdP, _) {
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: landProdP.isSaving
                              ? null
                              : () async {
                                  if (landP.selectedLandId == null ||
                                      prodP.selectedAnimalId == null ||
                                      quantityController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please fill all fields"),
                                      ),
                                    );
                                    return;
                                  }

                                  String? msg = await landProdP.saveAnimal(
                                    landId: landP.selectedLandId!,
                                    productId: prodP.selectedAnimalId!,
                                    quantity: quantityController.text.trim(),
                                  );

                                  if (msg != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );

                                    quantityController.clear();
                                    prodP.selectedAnimalId = null;
                                    prodP.notifyListeners();

                                    landProdP.fetchLandProducts(
                                      landId: landP.selectedLandId!,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              106,
                              239,
                              111,
                              0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: landProdP.isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 👇 Reusable Expandable Section
  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Title area with background color
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              height: 45,
              //width: MediaQuery.sizeOf(context).width*0.65,
              decoration: BoxDecoration(
                color: const Color(0xFFDFFFD9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.green,
                ),
                onTap: onToggle,
              ),
            ),
          ),

          // Expanded content with border
          if (expanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(45, 252, 12, 0.3)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

class LandDropdown extends StatelessWidget {
  final String hint;
  final Function(int landId)? onSelected;

  const LandDropdown({super.key, this.hint = "Select Land", this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<LandDetailsProvider>(
      builder: (context, landP, _) {
        if (landP.isLoadingList) {
          return const Center(child: CircularProgressIndicator());
        }

        if (landP.lands.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(232, 229, 229, 0.75),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: null,
                  hint: const Text(
                    "Select Land",
                    style: TextStyle(color: Colors.grey),
                  ),
                  icon: const Icon(Icons.arrow_drop_down),

                  /// Only one item — "No land available"
                  items: const [
                    DropdownMenuItem<String>(
                      value: "no_land",
                      child: Text(
                        "No land available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],

                  onChanged: (value) {
                    // Do nothing or show a snackbar if needed
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text("No land available")),
                    // );
                  },
                ),
              ),
            ),
          );
        }

        // -----------------------------
        // FIX: Safe selected value (ID)
        // -----------------------------
        final safeValue =
            (landP.selectedLandId != null &&
                landP.lands.any((e) => e.id == landP.selectedLandId))
            ? landP.selectedLandId
            : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromRGBO(232, 229, 229, 0.75),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: safeValue, // now ID
                hint: Text(hint, style: const TextStyle(color: Colors.grey)),
                icon: const Icon(Icons.arrow_drop_down),

                items: landP.lands.map((land) {
                  return DropdownMenuItem<int>(
                    value: land.id, // Only ID used internally
                    child: Text(land.landName), // Show name
                  );
                }).toList(),

                onChanged: (value) {
                  if (value == null) return;

                  final selectedLand = landP.lands.firstWhere(
                    (e) => e.id == value,
                  );

                  landP.selectLand(selectedLand);

                  if (onSelected != null) {
                    onSelected!(value); // return landId
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
