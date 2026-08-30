import 'package:get/get.dart';
import 'product_details_controller.dart';
import '../../../data/repositories/product_repository.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<ProductDetailsController>(() => ProductDetailsController());
  }
}
