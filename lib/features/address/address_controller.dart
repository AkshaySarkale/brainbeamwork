import 'package:get/get.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_controller.dart';

class AddressController extends GetxController {
  final AddressRepository _addressRepo = Get.find<AddressRepository>();

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.find<AuthController>().firebaseUser.value != null) {
      fetchAddresses();
    }
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final fetched = await _addressRepo.getAddresses();
      addresses.assignAll(fetched);
      
      if (addresses.isNotEmpty) {
        final def = addresses.firstWhereOrNull((a) => a.isDefault);
        selectedAddress.value = def ?? addresses.first;
      } else {
        selectedAddress.value = null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load addresses.';
      AppUtils.showSnackbar('Error', 'Unable to fetch addresses.', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      isSaving.value = true;
      final isFirstAddress = addresses.isEmpty;
      final newAddress = address.copyWith(isDefault: isFirstAddress || address.isDefault);
      
      await _addressRepo.addAddress(newAddress);
      
      if (newAddress.isDefault && !isFirstAddress) {
        // Optimistically update other defaults locally
        for (int i = 0; i < addresses.length; i++) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
      
      await fetchAddresses(); // Re-fetch to get correct IDs
      AppUtils.showSnackbar('Success', 'Address added successfully.');
      Get.back(); // Go back from add address view
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Failed to add address.', isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      isSaving.value = true;
      await _addressRepo.deleteAddress(id);
      addresses.removeWhere((a) => a.id == id);
      
      if (selectedAddress.value?.id == id) {
        selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
      }
      
      AppUtils.showSnackbar('Success', 'Address deleted.');
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Failed to delete address.', isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      isSaving.value = true;
      await _addressRepo.setDefaultAddress(id);
      
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: addresses[i].id == id);
      }
      addresses.refresh();
      
      final def = addresses.firstWhereOrNull((a) => a.id == id);
      if (def != null) {
        selectedAddress.value = def;
      }
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Failed to set default address.', isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
    Get.back(); // Usually called from checkout when picking an address
  }
}
