import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/splash/splash_binding.dart';
import '../../features/splash/splash_view.dart';
import '../../features/home/home_binding.dart';
import '../../features/home/home_view.dart';
import '../../features/auth/login_view.dart';
import '../../features/auth/register_view.dart';
import '../../features/auth/forgot_password_view.dart';
import '../../features/category/category_binding.dart';
import '../../features/category/category_view.dart';
import '../../features/product/product_binding.dart';
import '../../features/product/product_view.dart';
import '../../features/product/product_details/product_details_binding.dart';
import '../../features/product/product_details/product_details_view.dart';

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
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),
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
  ];
}
