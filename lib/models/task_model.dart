import 'package:flutter/foundation.dart';

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double? discount;
  final String? notes;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.discount,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString(),
      quantity:
          json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0,
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      discount: json['discount'] != null
          ? double.parse(json['discount'].toString())
          : null,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'notes': notes,
    };
  }
}

class TrackingInfo {
  final String id;
  final String orderId;
  final String status;
  final String? trackingNumber;
  final String? carrier;
  final DateTime? estimatedDelivery;
  final DateTime updatedAt;

  TrackingInfo({
    required this.id,
    required this.orderId,
    required this.status,
    this.trackingNumber,
    this.carrier,
    this.estimatedDelivery,
    required this.updatedAt,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      trackingNumber: json['tracking_number']?.toString(),
      carrier: json['carrier']?.toString(),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'status': status,
      'tracking_number': trackingNumber,
      'carrier': carrier,
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Task {
  final String id;
  final String orderNumber;
  final String customerId;
  final String deliveryAddress;
  final String deliveryTime;
  final String paymentMethod;
  final double totalAmount;
  final List<OrderItem> orderItems;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? workerId;
  final TrackingInfo? trackingInfo;

  Task({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.deliveryAddress,
    required this.deliveryTime,
    required this.paymentMethod,
    required this.totalAmount,
    required this.orderItems,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.workerId,
    this.trackingInfo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ??
          json['order_number']?.toString() ??
          '',
      customerId: json['customerId']?.toString() ??
          json['customer_id']?.toString() ??
          '',
      deliveryAddress: json['deliveryAddress']?.toString() ??
          json['delivery_address']?.toString() ??
          '',
      deliveryTime: json['deliveryTime']?.toString() ??
          json['delivery_time']?.toString() ??
          '',
      paymentMethod: json['paymentMethod']?.toString() ??
          json['payment_method']?.toString() ??
          '',
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : (json['total_amount'] != null
              ? (json['total_amount'] as num).toDouble()
              : 0.0),
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : json['order_items'] != null
              ? (json['order_items'] as List<dynamic>)
                  .map((item) =>
                      OrderItem.fromJson(item as Map<String, dynamic>))
                  .toList()
              : [],
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString())
              : null,
      workerId: json['workerId']?.toString() ?? json['worker_id']?.toString(),
      trackingInfo: json['trackingInfo'] != null
          ? TrackingInfo.fromJson(json['trackingInfo'] as Map<String, dynamic>)
          : json['tracking_info'] != null
              ? TrackingInfo.fromJson(
                  json['tracking_info'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'deliveryAddress': deliveryAddress,
      'deliveryTime': deliveryTime,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'workerId': workerId,
      'trackingInfo': trackingInfo?.toJson(),
    };
  }

  Task copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? deliveryAddress,
    String? deliveryTime,
    String? paymentMethod,
    double? totalAmount,
    List<OrderItem>? orderItems,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workerId,
    TrackingInfo? trackingInfo,
  }) {
    return Task(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      orderItems: orderItems ?? this.orderItems,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workerId: workerId ?? this.workerId,
      trackingInfo: trackingInfo ?? this.trackingInfo,
    );
  }
}
