import 'package:cloud_firestore/cloud_firestore.dart';

class Student{
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? matricNo;
  final bool? matricEdited;
  final String? img;
  final List? lecturesAttend;
  final bool? isLecturer;

  Student({this.isLecturer,this.email, this.firstname, this.lastname, this.matricNo, this.matricEdited, this.img, this.lecturesAttend});

  factory Student.fromJson(Map<String, dynamic> json){
    return Student(
        email: json['email'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        matricNo: json['matricNo'],
        matricEdited: json['matric_edited'],
        img: json['img'],
      lecturesAttend: json['lectures_attend'],
    );
  }

  factory Student.fromSnap(DocumentSnapshot snapshot){
    return Student(
        email: snapshot['email'],
        firstname: snapshot['firstname'],
        lastname: snapshot['lastname'],
        matricNo: snapshot['matricNo'],
        matricEdited: snapshot['matric_edited'],
        img: snapshot['img'],
        lecturesAttend: snapshot['lectures_attend'],
      isLecturer: snapshot['isLecturer']
    );
  }

}