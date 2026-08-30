import 'package:get/get.dart';
import 'package:shopora/data/models/category_model.dart';
import 'package:shopora/data/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository = Get.find<CategoryRepository>();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedCategories = await _repository.getCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
      errorMessage.value = 'Unable to load categories. Try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
