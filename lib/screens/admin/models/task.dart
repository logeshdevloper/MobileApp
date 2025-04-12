import 'package:intl/intl.dart';

class Task {
  final String id;
  final String orderNumber;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double totalAmount;
  final String customerId;
  final String deliveryAddress;
  final String deliveryTime;
  final String paymentMethod;
  final List<OrderItem> orderItems;
  final OrderTracking? trackingInfo;

  Task({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.totalAmount,
    required this.customerId,
    required this.deliveryAddress,
    required this.deliveryTime,
    required this.paymentMethod,
    required this.orderItems,
    this.trackingInfo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      customerId: json['customer_id'].toString(),
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryTime: json['delivery_time'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      orderItems: json['order_items'] != null
          ? List<OrderItem>.from(
              json['order_items'].map((x) => OrderItem.fromJson(x)))
          : [],
      trackingInfo: json['tracking_info'] != null
          ? OrderTracking.fromJson(json['tracking_info'])
          : null,
    );
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'New';
      case 'confirmed':
        return 'Preparing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      default:
        return status.substring(0, 1).toUpperCase() + status.substring(1);
    }
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;
  final double? discount;
  final String? notes;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.price,
    this.discount,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      name: json['product_name'] ?? '',
      imageUrl: json['product_image'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      discount: json['discount'] != null
          ? (json['discount'] as num).toDouble()
          : null,
      notes: json['notes'],
    );
  }
}

class OrderTracking {
  final String id;
  final String orderId;
  final String status;
  final String? trackingNumber;
  final String? carrier;
  final DateTime? estimatedDelivery;
  final DateTime updatedAt;

  OrderTracking({
    required this.id,
    required this.orderId,
    required this.status,
    this.trackingNumber,
    this.carrier,
    this.estimatedDelivery,
    required this.updatedAt,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      status: json['status'] ?? '',
      trackingNumber: json['tracking_number'],
      carrier: json['carrier'],
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
