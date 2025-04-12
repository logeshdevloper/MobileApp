class Worker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime joinDate;
  final bool isActive;
  final int completedTasks;
  final double rating;
  final List<String>? assignedTaskIds;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.isActive,
    required this.completedTasks,
    required this.rating,
    this.assignedTaskIds,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] ?? '',
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      completedTasks: json['completedTasks'] ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      assignedTaskIds: (json['assignedTaskIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'completedTasks': completedTasks,
      'rating': rating,
      'assignedTaskIds': assignedTaskIds,
    };
  }

  Worker copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? joinDate,
    bool? isActive,
    int? completedTasks,
    double? rating,
    List<String>? assignedTaskIds,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      completedTasks: completedTasks ?? this.completedTasks,
      rating: rating ?? this.rating,
      assignedTaskIds: assignedTaskIds ?? this.assignedTaskIds,
    );
  }
}
