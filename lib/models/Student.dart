class Student{
  final String email;
  final String firstname;
  final String lastname;
  final String matricNo;
  final bool matricEdited;
  final String img;
  final List lecturesAttend;

  Student({this.email, this.firstname, this.lastname, this.matricNo, this.matricEdited, this.img, this.lecturesAttend});

  factory Student.fromJson(Map<String, dynamic> json){
    return Student(
        email: json['email'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        matricNo: json['matric_no'],
        matricEdited: json['matric_edited'],
        img: json['img'],
      lecturesAttend: json['lectures_attend']
    );
  }

}