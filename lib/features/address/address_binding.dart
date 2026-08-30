import 'package:get/get.dart';
import '../../data/repositories/address_repository.dart';
import 'address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(() => AddressRepository(), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
  }
}
