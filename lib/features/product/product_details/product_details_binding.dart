import 'package:get/get.dart';
import 'package:shopora/features/product/product_details/product_details_controller.dart';
import 'package:shopora/data/repositories/product_repository.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<ProductDetailsController>(() => ProductDetailsController());
  }
}
