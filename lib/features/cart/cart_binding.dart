import 'package:get/get.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
