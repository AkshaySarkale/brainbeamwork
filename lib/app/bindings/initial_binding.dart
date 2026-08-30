import 'package:get/get.dart';
import '../../core/services/firebase_service.dart';
import '../../features/auth/auth_binding.dart';
import '../../data/repositories/cart_repository.dart';
import '../../features/cart/cart_controller.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../features/wishlist/wishlist_controller.dart';
import '../../data/repositories/user_repository.dart';
import '../../features/profile/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService(), permanent: true);
    AuthBinding().dependencies();
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<WishlistRepository>(() => WishlistRepository(), fenix: true);
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
