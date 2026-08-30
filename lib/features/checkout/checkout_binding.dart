import 'package:get/get.dart';
import 'package:shopora/data/repositories/order_repository.dart';
import 'package:shopora/features/checkout/checkout_controller.dart';
import 'package:shopora/features/address/address_controller.dart';
import 'package:shopora/data/repositories/address_repository.dart';

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
