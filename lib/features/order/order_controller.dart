import 'package:get/get.dart';
import 'package:shopora/data/models/order_model.dart';
import 'package:shopora/data/repositories/order_repository.dart';
import 'package:shopora/core/utils/app_utils.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepo = Get.find<OrderRepository>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.find<AuthController>().firebaseUser.value != null) {
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetched = await _orderRepo.getOrders();
      orders.assignAll(fetched);
    } catch (e) {
      errorMessage.value = 'Failed to load orders.';
      AppUtils.showSnackbar(
        'Error',
        'Unable to fetch order history.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
