class Student {
  final String? id;
  final String name;
  final String studentId;

  Student({this.id, required this.name, required this.studentId});

  Map<String, dynamic> toJson() {
    return {"name": name, "studentId": studentId};
  }

  factory Student.fromJson(Map<String, dynamic> json, String id) {
    return Student(
      id: id,
      name: json["name"] ?? "",
      studentId: json["studentId"] ?? "",
    );
  }
}
