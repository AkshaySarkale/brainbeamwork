import 'package:get/get.dart';
import 'package:shopora/data/repositories/product_repository.dart';
import 'package:shopora/features/product/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
  }
}
