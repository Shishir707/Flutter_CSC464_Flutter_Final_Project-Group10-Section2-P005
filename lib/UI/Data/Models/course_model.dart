class Course {
  final String? id;
  final String name;
  final String code;

  Course({this.id, required this.name, required this.code});

  Map<String, dynamic> toJson() {
    return {"name": name, "code": code};
  }

  factory Course.fromJson(Map<String, dynamic> json, String id) {
    return Course(id: id, name: json["name"] ?? "", code: json["code"] ?? "");
  }
}
