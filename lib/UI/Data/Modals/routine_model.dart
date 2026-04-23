class Routine {
  final String? id;
  final String courseId;
  final String day;
  final String time;

  Routine({
    this.id,
    required this.courseId,
    required this.day,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "courseId": courseId,
      "day": day,
      "time": time,
      "createdAt": DateTime.now(),
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json, String id) {
    return Routine(
      id: id,
      courseId: json["courseId"] ?? "",
      day: json["day"] ?? "",
      time: json["time"] ?? "",
    );
  }
}
