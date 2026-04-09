class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? campId;
  final Map<String, dynamic>? campData;
  final String? appointmentId;      // ✅ NEW
  final Map<String, dynamic>? appointmentData; // ✅ NEW
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.campId,
    this.campData,
    this.appointmentId,      // ✅ NEW
    this.appointmentData,    // ✅ NEW
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      campId: json['campId']?.toString(),
      campData: json['campData'],
      appointmentId: json['appointmentId']?.toString(),  // ✅ NEW
      appointmentData: json['appointmentData'],          // ✅ NEW
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'campId': campId,
      'campData': campData,
      'appointmentId': appointmentId,    // ✅ NEW
      'appointmentData': appointmentData, // ✅ NEW
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
  
  // Helper getters
  bool get isHealthCampNotification => type.startsWith('HEALTH_CAMP');
  bool get isAppointmentNotification => type.startsWith('APPOINTMENT');
}