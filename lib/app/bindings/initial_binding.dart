import 'package:get/get.dart';
import 'package:shopora/core/services/firebase_service.dart';
import 'package:shopora/features/auth/auth_binding.dart';
import 'package:shopora/data/repositories/cart_repository.dart';
import 'package:shopora/features/cart/cart_controller.dart';
import 'package:shopora/data/repositories/wishlist_repository.dart';
import 'package:shopora/features/wishlist/wishlist_controller.dart';
import 'package:shopora/data/repositories/user_repository.dart';
import 'package:shopora/features/profile/profile_controller.dart';
import 'package:shopora/data/repositories/notification_repository.dart';
import 'package:shopora/features/notification/notification_controller.dart';

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
    Get.put<NotificationRepository>(NotificationRepository(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
  }
}
