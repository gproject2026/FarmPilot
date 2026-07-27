class CartItem {
  final String productId;
  final String name;
  final double price;
  final String unit;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toOrderItem() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}