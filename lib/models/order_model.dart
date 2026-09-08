class Order {
  final String id;
  final String userEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status; // pending, confirmed, shipped, delivered
  final String deliveryAddress;

  Order({
    required this.id,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'confirmed',
    required this.deliveryAddress,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
  });

  double get totalPrice => productPrice * quantity;
}
