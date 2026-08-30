import 'package:get/get.dart';
import '../../data/repositories/wishlist_repository.dart';
import 'wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependencies exist, usually provided by InitialBinding
    if (!Get.isRegistered<WishlistRepository>()) {
      Get.lazyPut<WishlistRepository>(() => WishlistRepository(), fenix: true);
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
    }
  }
}
