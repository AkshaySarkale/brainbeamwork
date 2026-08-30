import 'package:get/get.dart';
import 'package:shopora/data/repositories/address_repository.dart';
import 'package:shopora/features/address/address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(() => AddressRepository(), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
  }
}
