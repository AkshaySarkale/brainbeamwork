import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'address_controller.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/address_model.dart';

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

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
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
      _addressControllerService.addAddress(newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address')),
      body: Stack(
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
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hintText: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
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
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          hintText: 'City',
                          controller: _cityController,
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          hintText: 'State',
                          controller: _stateController,
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
                  ElevatedButton(
                    onPressed: _saveAddress,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Save Address'),
                    ),
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
    );
  }
}
