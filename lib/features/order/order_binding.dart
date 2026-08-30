import 'package:get/get.dart';
import 'package:shopora/data/repositories/order_repository.dart';
import 'package:shopora/features/order/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);
    }
    Get.lazyPut<OrderController>(() => OrderController());
  }
}
