import 'package:get/get.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Controller is globally injected in initial_binding for the badge to work.
    // If we wanted local, it would be here. But since we need the badge,
    // we will inject it in InitialBinding and just rely on that here.
    // We can leave this empty or Get.lazyPut it if we change architecture.
  }
}
