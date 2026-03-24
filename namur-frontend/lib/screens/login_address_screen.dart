import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../provider/district_provider.dart';
import 'home_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtl = TextEditingController();
  final _ageCtl = TextEditingController();

  bool _agree = true;
  bool _mobileHasError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<DistrictProvider>(context, listen: false).loadDistricts();
  }

  @override
  void dispose() {
    _mobileCtl.dispose();
    _ageCtl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final provider = Provider.of<DistrictProvider>(context, listen: false);

    if (!_agree) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_agree_terms'.tr())));
      return;
    }

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        _mobileHasError =
            _mobileCtl.text.isEmpty || _mobileCtl.text.length < 10;
      });
      return;
    }

    if (provider.selectedDistrict == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('select_district'.tr())));
      return;
    }

    if (provider.selectedProfession == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('select_profession'.tr())));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await provider.saveBasicDetails(
      mobile: _mobileCtl.text.trim(),
      profession: provider.selectedProfession!,
      age: int.tryParse(_ageCtl.text.trim()) ?? 0,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('details_saved'.tr())));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('details_failed'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DistrictProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/farm_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'address'.tr(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E7A3F),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildMobileField(),
                                  const SizedBox(height: 12),
                                  _buildDropdownField(
                                    label: 'district'.tr(),
                                    value: provider.selectedDistrict,
                                    items: provider.districts,
                                    onChanged: (v) => provider.setDistrict(v!),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDropdownField(
                                    label: 'profession'.tr(),
                                    value: provider.selectedProfession,
                                    items: const [
                                      "Farmer",
                                      "Trader",
                                      "Worker",
                                      "Student",
                                      "Other",
                                    ],
                                    onChanged: (v) =>
                                        provider.setProfession(v!),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildTextField(
                                    controller: _ageCtl,
                                    hint: 'age'.tr(),
                                    keyboard: TextInputType.number,
                                  ),
                                  const SizedBox(height: 24),
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : ElevatedButton(
                                          onPressed: _onNext,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            minimumSize: const Size(140, 48),
                                          ),
                                          child: Text(
                                            'next'.tr(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF1E7A3F),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agree,
                        onChanged: (v) {
                          setState(() => _agree = v ?? false);
                        },
                        activeColor: const Color(0xFF1E7A3F),
                      ),
                      Expanded(
                        child: Text(
                          'I agree to terms and conditions & privacy policy',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _mobileCtl,
          maxLength: 10,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          validator: (v) {
            if (v == null || v.isEmpty) return 'required'.tr();
            if (v.length < 10) return 'invalid_number'.tr();
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Text(
                '+91',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: 'enter_mobile'.tr(),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        hint: Text(label),
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
