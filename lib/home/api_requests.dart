// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uniben_attendance_stud/models/Student.dart';
import 'package:uniben_attendance_stud/models/lecture.dart';

import 'homepage.dart';

FirebaseAuth auth = FirebaseAuth.instance;

Future signUpRequest(email, matricNo, password,firstName,lastName,context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  try{
    auth.createUserWithEmailAndPassword(
        email: email, password: password).then((UserCredential value) {
          print('laught');
      FirebaseFirestore.instance.collection('students').
      doc(auth.currentUser!.uid.toString()).set({
        "email": email,
        'firstname':firstName,
        'lastname':lastName,
        'matric_edited':false,
        'img': '',
        'lectures_attend':[],
        'isLecturer':false,
        'id':auth.currentUser!.uid,
        'matricNo':matricNo,

      }).then((value) {
        pref.setString('firstname',firstName);
        pref.setString('lastname', lastName);
        pref.setString('email',email);
        pref.setString('matricNo', matricNo);
        pref.setBool('logged_in', true);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => HomePage(null)));
      });
    }).catchError((e) {
      String error = '[firebase_auth/email-already-in-use] The email address is already in use by another account.';
      if (e.toString().contains(error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('This Account Already Exist')));
      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Network Problems')));
      }
      print(e);
    });
    print('done with signUp');
  }catch(e){
    print(e.toString());
  }
}

Future loginRequest(email, password,context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  try{
    auth.signInWithEmailAndPassword(email: email, password: password).
    then((value) {
       FirebaseFirestore.instance.collection('students')
          .doc(auth.currentUser!.uid.toString()).get().then((DocumentSnapshot docSnap) {
            Student student = Student.fromSnap(docSnap);
            pref.setString('firstname', student.firstname!);
            pref.setString('lastname', student.lastname!);
            pref.setString('email', student.email!);
            pref.setString('matricNo', student.matricNo!);
            pref.setBool('logged_in', true);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HomePage(null)));
       });
    }).catchError((e) {
      String error = '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.';
      if (e.toString().contains(error)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('This Account Do not Exist')));
      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Network Problems')));
      }
      print(e);
    });
    print('done with login');
  }catch(e){
    print(e);
  }
}

attendLectureRequest(lectureToken,context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  try{

    FirebaseFirestore.instance.collection('lecturers').doc(lectureToken).get()
        .then((DocumentSnapshot value) {
     List val =  value['generateLecture'];
     Map map = val.last;
     List attendees = map['attendees'];
    if(!attendees.contains(auth.currentUser!.uid)){
      attendees.add(auth.currentUser!.uid);
      map.update('attendees', (value) => attendees);
      val.removeLast();
      val.add(map);
    }
     FirebaseFirestore.instance.collection('lecturers').doc(lectureToken).update({
       'generateLecture':val
     });
     FirebaseFirestore.instance.collection('students')
         .doc(auth.currentUser!.uid).get().then((doc){
       List lectureAttend = doc['lectures_attend'];
       lectureAttend.add(map);
       FirebaseFirestore.instance.collection('students')
           .doc(auth.currentUser!.uid).update({
         'lectures_attend':lectureAttend
       });
     }).catchError((e){

       ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Failed To Scan')));
     });
    }).catchError((e){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed To Scan')));
    });
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed To Scan')));
  }


}

getLectures() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? token = pref.getString('token');

  http.Client client = http.Client();
  try{
    http.Response response = await client.post(
        Uri.https('serene-harbor-85025.herokuapp.com', '/students/getlectures'),
        body: json.encode({
          "token": token
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    dynamic decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List<Lecture> lectures = [];
    if(decodedResponse['status'] == 'ok'){
      decodedResponse['lectures_attend'].forEach((lecture){
        lectures.add(Lecture.fromJson(lecture));
      });
      return {
        'status': 'ok',
        'lectures': lectures
      };
    }else{
      return {
        'status': 'error',
        'msg': decodedResponse['msg'].toString()
      };
    }
  }catch(e){
    return {
      'status': 'error',
      'msg': e
    };
  }
}


editProfile(firstname, lastname,matricNo , BuildContext context) async {

  SharedPreferences pref = await SharedPreferences.getInstance();

  try{
    FirebaseFirestore.instance.collection('students').
    doc(auth.currentUser!.uid.toString()).update({
      'firstname':firstname,
      'lastname':lastname,
      'matricNo':matricNo
    }).then((value) {

      pref.setString('firstname', firstname);
      pref.setString('lastname', lastname);
      pref.setString('matricNo', matricNo);
      Navigator.pop(context);
    });


  }catch(e){
    print(e);
  }
}
