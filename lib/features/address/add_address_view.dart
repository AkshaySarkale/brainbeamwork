import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shopora/features/address/address_controller.dart';
import 'package:shopora/core/widgets/app_text_field.dart';
import 'package:shopora/core/widgets/app_button.dart';
import 'package:shopora/core/utils/app_utils.dart';
import 'package:shopora/data/models/address_model.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinController = TextEditingController();
  final _landmarkController = TextEditingController();

  final AddressController _addressControllerService = Get.find<AddressController>();
  
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _cityController.addListener(_validateForm);
    _stateController.addListener(_validateForm);
    _pinController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isNameValid = _nameController.text.trim().isNotEmpty;
    final isPhoneValid = _phoneController.text.trim().length == 10;
    final isAddressValid = _addressController.text.trim().isNotEmpty;
    final isCityValid = _cityController.text.trim().isNotEmpty;
    final isStateValid = _stateController.text.trim().isNotEmpty;
    final isPinValid = _pinController.text.trim().length == 6;

    final isValid = isNameValid && isPhoneValid && isAddressValid && isCityValid && isStateValid && isPinValid;
    
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate() && _isFormValid) {
      final newAddress = AddressModel(
        id: '', // Firestore will generate this
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _pinController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        isDefault: false,
      );
      final success = await _addressControllerService.addAddress(newAddress);
      if (success) {
        Get.back();
        Future.delayed(const Duration(milliseconds: 100), () {
          AppUtils.showSnackbar('Success', 'Address added successfully.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address')),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    hintText: 'Full Name',
                    controller: _nameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    onChanged: (_) => _validateForm(),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hintText: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) => _validateForm(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (val.length < 10) return 'Enter valid 10-digit number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hintText: 'Address Line (House No, Building, Street)',
                    controller: _addressController,
                    onChanged: (_) => _validateForm(),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          hintText: 'City',
                          controller: _cityController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          ],
                          onChanged: (_) => _validateForm(),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          hintText: 'State',
                          controller: _stateController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                          ],
                          onChanged: (_) => _validateForm(),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hintText: 'Postal Code',
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (_) => _validateForm(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (val.length != 6) return 'Enter valid 6-digit PIN';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hintText: 'Landmark (Optional)',
                    controller: _landmarkController,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Save Address',
                    onPressed: _isFormValid ? _saveAddress : null,
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (_addressControllerService.isSaving.value) {
              return Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      ),
    );
  }
}
