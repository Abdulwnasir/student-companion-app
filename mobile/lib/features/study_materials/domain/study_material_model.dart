class StudyMaterial {
  final String id;
  final String title;
  final String courseName;
  final String fileUrl;
  final String fileType;
  final String userId;
  final String? departmentId;
  final String? batchId;
  final String? sectionId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.courseName,
    required this.fileUrl,
    required this.fileType,
    required this.userId,
    this.departmentId,
    this.batchId,
    this.sectionId,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      courseName: json['courseName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      userId: json['userId'] ?? '',
      departmentId: json['departmentId'],
      batchId: json['batchId'],
      sectionId: json['sectionId'],
      isPublic: json['isPublic'] == true || json['isPublic'] == 1,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courseName': courseName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'userId': userId,
      'departmentId': departmentId,
      'batchId': batchId,
      'sectionId': sectionId,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
