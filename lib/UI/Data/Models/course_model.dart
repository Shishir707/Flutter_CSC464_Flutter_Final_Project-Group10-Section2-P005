class Course {
  final String courseId;
  final String title;
  final double credit;
  final String department;
  final DateTime createdAt;

  Course({
    required this.courseId,
    required this.title,
    required this.credit,
    required this.department,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "courseId": courseId,
      "title": title,
      "credit": credit,
      "department": department,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json["courseId"] ?? "",
      title: json["title"] ?? "",
      credit: (json["credit"] ?? 0).toDouble(),
      department: json["department"] ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }
}
