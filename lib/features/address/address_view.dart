import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/address/address_controller.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/core/widgets/app_empty_state.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';

class AddressView extends GetView<AddressController> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSelectionMode = Get.arguments?['isSelectionMode'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? 'Select Address' : 'My Addresses'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ListShimmer();
          }

        if (controller.addresses.isEmpty) {
          return AppEmptyState(
            icon: Icons.location_on_outlined,
            title: 'No saved addresses',
            message: 'Add an address for faster checkout.',
            buttonText: 'Add Address',
            onButtonPressed: () => Get.toNamed(AppRoutes.addAddress),
          );
        }

        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = controller.addresses[index];
                return GestureDetector(
                  onTap: isSelectionMode
                      ? () => controller.selectAddress(address)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: address.isDefault
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: address.isDefault ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              address.fullName,
                              style: AppTextStyles.heading2,
                            ),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(address.phone, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${address.addressLine}, ${address.city}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          '${address.state} - ${address.postalCode}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        if (address.landmark?.isNotEmpty == true)
                          Text(
                            'Landmark: ${address.landmark}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!address.isDefault)
                              TextButton(
                                onPressed: () =>
                                    controller.setDefaultAddress(address.id),
                                child: const Text('Set as Default'),
                              ),
                            TextButton(
                              onPressed: () =>
                                  controller.deleteAddress(address.id),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (controller.isSaving.value)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
      ),
      floatingActionButton: Obx(() {
        if (controller.addresses.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.addAddress),
          label: const Text('Add New Address'),
          icon: const Icon(Icons.add),
        );
      }),
    );
  }
}
