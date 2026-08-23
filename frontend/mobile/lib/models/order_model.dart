class OrderModel {
  final String id;
  final String customerId;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderCustomer customer;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      totalPrice: double.tryParse(json['totalPrice'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      customer: OrderCustomer.fromJson(
        json['customer'] as Map<String, dynamic>? ?? {},
      ),
      orderItems:
          (json['orderItems'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    OrderItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

class OrderCustomer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String address;
  final String? profileImage;

  OrderCustomer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    this.profileImage,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final OrderProduct product;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      product: OrderProduct.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class OrderProduct {
  final String id;
  final String farmerId;
  final String categoryId;

  final String name;
  final String? nameEn;
  final String? nameAr;

  final String description;
  final String? descriptionEn;
  final String? descriptionAr;

  final double price;
  final int quantity;
  final String unit;
  final String? imageUrl;
  final String status;

  final OrderFarmer farmer;
  final OrderCategory category;

  OrderProduct({
    required this.id,
    required this.farmerId,
    required this.categoryId,
    required this.name,
    this.nameEn,
    this.nameAr,
    required this.description,
    this.descriptionEn,
    this.descriptionAr,
    required this.price,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    required this.status,
    required this.farmer,
    required this.category,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString(),
      nameAr: json['nameAr']?.toString(),
      description: json['description']?.toString() ?? '',
      descriptionEn: json['descriptionEn']?.toString(),
      descriptionAr: json['descriptionAr']?.toString(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      unit: json['unit']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      status: json['status']?.toString() ?? '',
      farmer: OrderFarmer.fromJson(
        json['farmer'] as Map<String, dynamic>? ?? {},
      ),
      category: OrderCategory.fromJson(
        json['category'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  String localizedName(bool isArabic) {
    final preferred =
        isArabic ? nameAr?.trim() : nameEn?.trim();

    if (preferred != null && preferred.isNotEmpty) {
      return preferred;
    }

    final fallback = name.trim();

    if (fallback.isNotEmpty) {
      return fallback;
    }

    return isArabic ? 'منتج' : 'Product';
  }
}

class OrderFarmer {
  final String id;
  final String fullName;
  final String email;
  final String phone;

  OrderFarmer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory OrderFarmer.fromJson(Map<String, dynamic> json) {
    return OrderFarmer(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class OrderCategory {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String description;
  final String? descriptionEn;
  final String? descriptionAr;

  OrderCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
    required this.description,
    this.descriptionEn,
    this.descriptionAr,
  });

  factory OrderCategory.fromJson(Map<String, dynamic> json) {
    return OrderCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString(),
      nameAr: json['nameAr']?.toString(),
      description: json['description']?.toString() ?? '',
      descriptionEn: json['descriptionEn']?.toString(),
      descriptionAr: json['descriptionAr']?.toString(),
    );
  }
}
