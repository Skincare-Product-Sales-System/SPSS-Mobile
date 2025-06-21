import 'package:flutter/material.dart';

/// Service để quản lý điều hướng từ bất kỳ đâu trong ứng dụng
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Lấy context hiện tại
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Điều hướng đến một route mới
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Điều hướng đến một route mới và xóa tất cả route trước đó
  Future<dynamic> navigateToAndClearStack(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Điều hướng về trang chủ
  void navigateToRoot() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  /// Quay lại màn hình trước đó
  void goBack() {
    navigatorKey.currentState!.pop();
  }

  /// Quay lại màn hình trước đó với kết quả
  void goBackWithResult(dynamic result) {
    navigatorKey.currentState!.pop(result);
  }

  /// Điều hướng và thay thế route hiện tại
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Điều hướng đến một route mới và xóa đến route cụ thể
  Future<dynamic> navigateToAndRemoveUntil(
    String routeName,
    String untilRouteName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      ModalRoute.withName(untilRouteName),
      arguments: arguments,
    );
  }

  /// Kiểm tra xem có thể quay lại không
  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  /// Quay lại nhiều lần
  void goBackMultiple(int times) {
    int count = 0;
    navigatorKey.currentState!.popUntil((route) {
      return count++ == times;
    });
  }

  /// Quay lại đến một route cụ thể
  void goBackTo(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
}
