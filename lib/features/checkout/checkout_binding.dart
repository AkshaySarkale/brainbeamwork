import 'package:get/get.dart';
import '../../data/repositories/order_repository.dart';
import 'checkout_controller.dart';
import '../address/address_controller.dart';
import '../../data/repositories/address_repository.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);
    
    // Ensure AddressRepository and AddressController exist before CheckoutController
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(() => AddressRepository(), fenix: true);
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    }
    
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
