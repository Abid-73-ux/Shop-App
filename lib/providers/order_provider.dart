import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final Map<String, List<Order>> _userOrders = {};

  List<Order> getUserOrders(String userEmail) {
    return _userOrders[userEmail.toLowerCase()] ?? [];
  }

  Future<Order> placeOrder({
    required String userEmail,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final order = Order(
        id: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
        userEmail: userEmail,
        items: items,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        status: 'confirmed',
        deliveryAddress: deliveryAddress,
      );

      final emailLower = userEmail.toLowerCase();
      if (!_userOrders.containsKey(emailLower)) {
        _userOrders[emailLower] = [];
      }
      _userOrders[emailLower]!.insert(0, order);

      notifyListeners();
      return order;
    } catch (e) {
      rethrow;
    }
  }

  int getOrderCount(String userEmail) {
    return getUserOrders(userEmail).length;
  }

  double getTotalSpent(String userEmail) {
    return getUserOrders(userEmail).fold(
      0.0,
      (sum, order) => sum + order.totalAmount,
    );
  }
}
