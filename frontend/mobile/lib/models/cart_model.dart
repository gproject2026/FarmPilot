class CartItem {
  final String productId;
  final String name;


  final double price;

  final String productUnit;

 
  String selectedUnit;

  final String? imageUrl;

  double quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required String unit,
    required num quantity,
    this.imageUrl,
    String? selectedUnit,
  })  : productUnit = unit,
        selectedUnit = selectedUnit ?? unit,
        quantity = quantity.toDouble();

  bool get supportsWeightConversion {
    final normalized = productUnit.trim().toLowerCase();

    return normalized == 'kg' ||
        normalized == 'ton';
  }

  List<String> get availableUnits {
    if (supportsWeightConversion) {
      return const [
        'kg',
        'ton',
      ];
    }

    return [
      productUnit,
    ];
  }

  double get quantityInProductUnit {
    final from = selectedUnit.trim().toLowerCase();
    final to = productUnit.trim().toLowerCase();

    if (from == to) {
      return quantity;
    }

    if (from == 'kg' && to == 'ton') {
      return quantity / 1000.0;
    }

    if (from == 'ton' && to == 'kg') {
      return quantity * 1000.0;
    }

    return quantity;
  }

  double get totalPrice {
    return price * quantityInProductUnit;
  }

  void changeUnit(String newUnit) {
    final normalizedNewUnit =
        newUnit.trim().toLowerCase();

    if (!availableUnits.contains(normalizedNewUnit)) {
      return;
    }

    if (selectedUnit == normalizedNewUnit) {
      return;
    }

    selectedUnit = normalizedNewUnit;

    quantity = 1.0;
  }

  Map<String, dynamic> toOrderItem() {
    return {
      'productId': productId,
      'quantity': quantity,
      'unit': selectedUnit,
    };
  }
}
