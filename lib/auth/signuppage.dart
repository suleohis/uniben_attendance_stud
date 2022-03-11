import 'package:flutter/material.dart';
import 'package:uniben_attendance_stud/home/api_requests.dart';
import 'package:uniben_attendance_stud/home/homepage.dart';
import 'package:uniben_attendance_stud/models/lecture.dart';

class SignUp extends StatefulWidget {

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  String email;
  String matricNo;
  String password;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green,
        body: Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Align(
                      child: Text('Sign Up', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                      alignment: Alignment.centerLeft,
                    ),
                    margin: const EdgeInsets.only(bottom: 25),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Column(
                      children: [
                        TextField(
                          enabled: !isLoading,
                          onChanged: (val){
                            email = val;
                          },
                          decoration: InputDecoration(
                              hintText: 'Email',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.email)
                          ),
                        ),

                        Container(
                            height: 0.5,
                            color: Colors.grey,
                            margin: const EdgeInsets.only(bottom: 4)
                        ),

                        TextField(
                          enabled: !isLoading,
                          onChanged: (val){
                            matricNo = val;
                          },
                          decoration: InputDecoration(
                              hintText: 'Matric. No.',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.info, color: Colors.yellow,),
                                onPressed: (){
                                  // show pop up telling the user that
                                },
                              ),
                              prefixIcon: Icon(Icons.school)
                          ),
                        ),

                        Container(
                            height: 0.5,
                            color: Colors.grey,
                            margin: const EdgeInsets.only(top: 4)
                        ),

                        TextField(
                          enabled: !isLoading,
                          obscureText: true,
                          onChanged: (val){
                            password = val;
                          },
                          decoration: InputDecoration(
                              hintText: 'Password',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.lock)
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                      margin: const EdgeInsets.only(top: 12),
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        color: Colors.amber,
                        child: InkWell(
                            splashColor: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                            onTap: isLoading ? null : () async {
                              await signUp(email, matricNo, password);
                            },
                            child: Container(

                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                  child: isLoading ? Container(height: 40, width: 40, child: CircularProgressIndicator()) : Text('sign up'.toUpperCase(), style: TextStyle(color: Colors.black))
                              ),
                            )
                        ),
                      )
                  ),


                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    margin: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: TextStyle()),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Login', style: TextStyle(color: Colors.yellow))
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        )
    );
  }

  List<Lecture> gLectures = [];
  signUp(email, matricNo, password) async {
    setState(() {
      isLoading = true;
    });
    if((email == null || email == '') || (matricNo == null || matricNo == '') || (password == null || password == '')){
      print('All fields must be properly entered');
      return;
    }
    dynamic result = await signUpRequest(email, matricNo, password);
    setState(() {
      isLoading = false;
    });
    if(result is Map){
      if(result['status'] == 'ok'){
        gLectures = result['lectures'];
        print(gLectures);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomePage(gLectures)));
      }else{
        // This is an error
        print(result);
      }
    }else{
      print(result);
    }
  }
}


