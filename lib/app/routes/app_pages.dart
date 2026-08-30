import 'package:get/get.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/features/splash/splash_binding.dart';
import 'package:shopora/features/splash/splash_view.dart';
import 'package:shopora/features/home/home_binding.dart';
import 'package:shopora/features/home/home_view.dart';
import 'package:shopora/features/auth/login_view.dart';
import 'package:shopora/features/auth/register_view.dart';
import 'package:shopora/features/auth/forgot_password_view.dart';
import 'package:shopora/features/category/category_binding.dart';
import 'package:shopora/features/category/category_view.dart';
import 'package:shopora/features/product/product_binding.dart';
import 'package:shopora/features/product/product_view.dart';
import 'package:shopora/features/product/product_details/product_details_binding.dart';
import 'package:shopora/features/product/product_details/product_details_view.dart';
import 'package:shopora/features/cart/cart_binding.dart';
import 'package:shopora/features/cart/cart_view.dart';
import 'package:shopora/features/address/address_binding.dart';
import 'package:shopora/features/address/address_view.dart';
import 'package:shopora/features/address/add_address_view.dart';
import 'package:shopora/features/checkout/checkout_binding.dart';
import 'package:shopora/features/checkout/checkout_view.dart';
import 'package:shopora/features/order/order_binding.dart';
import 'package:shopora/features/order/order_view.dart';
import 'package:shopora/features/order/order_details_view.dart';
import 'package:shopora/features/order/order_success_view.dart';
import 'package:shopora/features/wishlist/wishlist_binding.dart';
import 'package:shopora/features/wishlist/wishlist_view.dart';
import 'package:shopora/features/profile/profile_binding.dart';
import 'package:shopora/features/profile/profile_view.dart';
import 'package:shopora/features/profile/edit_profile_view.dart';
import 'package:shopora/features/profile/change_password_view.dart';
import 'package:shopora/features/notification/notification_binding.dart';
import 'package:shopora/features/notification/notification_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsView(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressView(),
      binding: AddressBinding(),
    ),
    GetPage(name: AppRoutes.addAddress, page: () => const AddAddressView()),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderView(),
      binding: OrderBinding(),
    ),
    GetPage(name: AppRoutes.orderDetails, page: () => const OrderDetailsView()),
    GetPage(name: AppRoutes.orderSuccess, page: () => const OrderSuccessView()),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
  ];
}
