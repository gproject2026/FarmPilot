class SupplierCartItem {
  final String productId;
  final String supplierId;
  final String name;
  final double price;
  final String unit;
  final String? imageUrl;
  final int availableQuantity;

  int quantity;

  SupplierCartItem({
    required this.productId,
    required this.supplierId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.availableQuantity,
    this.imageUrl,
  });

  double get totalPrice {
    return price * quantity;
  }

  bool get canIncrease {
    return quantity < availableQuantity;
  }

  Map<String, dynamic> toOrderItem() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}