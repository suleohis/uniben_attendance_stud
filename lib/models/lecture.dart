class Lecture{

  final String? lectureId;
  final String? createdAt;
  final String? classStart;
  final String? courseName;
  final String? courseCode;
  final String? session;
  final String? semester;

  Lecture({this.createdAt, this.classStart, this.courseName, this.courseCode, this.lectureId, this.session, this.semester});

  factory Lecture.fromJson(Map<String, dynamic> json){
    return Lecture(
        lectureId: json['lecture_id'],
        createdAt: json['created_at'].toString(),
        classStart: json['class_start'].toString(),
        courseName: json['course_name'],
        courseCode: json['course_code'],
        session: json['session'],
        semester: json['semester']
    );
  }
}