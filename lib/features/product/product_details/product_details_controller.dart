import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class ProductDetailsController extends GetxController {
  final ProductRepository _repository = Get.find<ProductRepository>();

  final Rx<ProductModel?> product = Rx<ProductModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final productIdStr = Get.parameters['id'];
    final productId = int.tryParse(productIdStr ?? '');
    
    if (productId != null) {
      fetchProductDetails(productId);
    } else {
      isLoading.value = false;
      errorMessage.value = 'Invalid product ID.';
    }
  }

  Future<void> fetchProductDetails(int productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetched = await _repository.getProductById(productId);
      if (fetched != null) {
        product.value = fetched;
      } else {
        errorMessage.value = 'Product not found.';
      }
    } catch (e) {
      errorMessage.value = 'Unable to load product details. Try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
