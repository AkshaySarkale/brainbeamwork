import 'package:get/get.dart';
import 'package:shopora/data/repositories/category_repository.dart';
import 'package:shopora/data/repositories/product_repository.dart';
import 'package:shopora/data/repositories/cart_repository.dart';
import 'package:shopora/features/category/category_controller.dart';
import 'package:shopora/features/cart/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
