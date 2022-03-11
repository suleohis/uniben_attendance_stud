import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uniben_attendance_stud/models/Student.dart';
import 'package:uniben_attendance_stud/models/lecture.dart';

signUpRequest(email, matricNo, password) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  http.Client client = http.Client();

  try{
    http.Response response = await client.post(
        Uri.https('serene-harbor-85025.herokuapp.com', '/students/signup'),
        body: json.encode({
          "email": email,
          "matric_no": matricNo,
          "password": password
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    dynamic decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    print('${decodedResponse['status']}, ${decodedResponse['user']}');
    List<Lecture> lectures = [];
    if(decodedResponse['status'] == 'ok'){
      Student student = Student.fromJson(decodedResponse['user']);
      pref.setString('token', decodedResponse['token']);
      pref.setString('firstname', student.firstname);
      pref.setString('lastname', student.lastname);
      pref.setString('email', student.email);
      pref.setBool('logged_in', true);
      // get lectures
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
    return e;
  }
}

loginRequest(email, password) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  http.Client client = http.Client();

  try{
    http.Response response = await client.post(
        Uri.https('serene-harbor-85025.herokuapp.com', '/students/login'),
        body: json.encode({
          "email": email,
          "password": password
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    dynamic decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List<Lecture> lectures = [];
    if(decodedResponse['status'] == 'ok'){
      Student student = Student.fromJson(decodedResponse['user']);
      pref.setString('token', decodedResponse['token']);
      pref.setString('firstname', student.firstname);
      pref.setString('lastname', student.lastname);
      pref.setString('email', student.email);
      pref.setBool('logged_in', true);
      // get lectures
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
    return e;
  }
}

attendLectureRequest(lectureToken) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String token = pref.getString('token');

  http.Client client = http.Client();
  try{
    http.Response response = await client.post(
        Uri.https('serene-harbor-85025.herokuapp.com', '/students/attendlecture'),
        body: json.encode({
          "token": token,
          "lectureToken": lectureToken
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

getLectures() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String token = pref.getString('token');

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


editProfile(firstname, lastname) async {

  SharedPreferences pref = await SharedPreferences.getInstance();
  String token = pref.getString('token');

  http.Client client = http.Client();

  try{
    http.Response response = await client.post(
        Uri.https('serene-harbor-85025.herokuapp.com', '/students/editprofile'),
        body: json.encode({
          "token": token,
          "firstname": firstname,
          "lastname": lastname
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );
    dynamic decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    print('${decodedResponse['status']}, ${decodedResponse['user']}');

    if(decodedResponse['status'] == 'ok'){
      
      pref.setString('firstname', firstname);
      pref.setString('lastname', lastname);

      return 'ok';
    }else{
      return 'error';
    }
  }catch(e){
    return e;
  }
}
