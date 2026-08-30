import 'package:get/get.dart';
import 'package:shopora/data/repositories/category_repository.dart';
import 'package:shopora/features/category/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
  }
}
