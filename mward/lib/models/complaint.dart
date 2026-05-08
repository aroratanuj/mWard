import 'package:json_annotation/json_annotation.dart';

part 'complaint.g.dart';

@JsonSerializable()
class Complaint {
  final String complaintId;
  final String userId;
  final String wardCode;
  final String title;
  final String description;
  final String category;
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'in-progress', 'resolved', 'rejected'
  final List<String> photoUrls;
  final List<String> videoUrls;
  final String? audioUrl;
  final LocationData location;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final String? resolutionNote;
  final List<Comment> comments;

  Complaint({
    required this.complaintId,
    required this.userId,
    required this.wardCode,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.photoUrls,
    this.videoUrls = const [],
    this.audioUrl,
    required this.location,
    this.address,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.assignedTo,
    this.resolutionNote,
    this.comments = const [],
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);

  Map<String, dynamic> toJson() => _$ComplaintToJson(this);

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in-progress';
  bool get isResolved => status == 'resolved';
  bool get isRejected => status == 'rejected';

  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';

  Complaint copyWith({
    String? complaintId,
    String? userId,
    String? wardCode,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    List<String>? photoUrls,
    List<String>? videoUrls,
    String? audioUrl,
    LocationData? location,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? assignedTo,
    String? resolutionNote,
    List<Comment>? comments,
  }) {
    return Complaint(
      complaintId: complaintId ?? this.complaintId,
      userId: userId ?? this.userId,
      wardCode: wardCode ?? this.wardCode,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      location: location ?? this.location,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      comments: comments ?? this.comments,
    );
  }
}

@JsonSerializable()
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

@JsonSerializable()
class Comment {
  final String commentId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
