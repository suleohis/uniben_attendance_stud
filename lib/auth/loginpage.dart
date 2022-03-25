import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uniben_attendance_stud/auth/signuppage.dart';
import 'package:uniben_attendance_stud/home/api_requests.dart';
import 'package:uniben_attendance_stud/home/homepage.dart';
import 'package:uniben_attendance_stud/models/lecture.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);


  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String email;
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
                  child: const Align(
                  child: Text('Login', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
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
                      decoration: const InputDecoration(
                        hintText: 'Email/Username',
                        border: InputBorder.none,
                          prefixIcon: Icon(Icons.email)
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
                      decoration: const InputDecoration(
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
                          await login(email, password);
                        },
                        child: Container(

                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Center(
                              child: isLoading ? const SizedBox(height: 40, width: 40, child: CircularProgressIndicator()) : Text('login'.toUpperCase(), style: const TextStyle(color: Colors.black))
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
                    const Text('Don\'t have an account?', style: TextStyle()),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder:
                              (_)=> const SignUp()));
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.yellow))
                    )
                  ],
                ),
              ),


            ],
          ),
        )
      )
    );
  }

  List<Lecture> gLectures = [];
  login(email, password) async {
    setState(() {
      isLoading = true;
    });
    if((email == null || email == '') || (password == null || password == '')){
      if (kDebugMode) {
        print('All fields must be properly entered');
        setState(() {
          isLoading = false;
        });
        return;
      }
    }
    loginRequest(email, password,context).then((value){

      setState(() {
        isLoading = false;
      });
    });


    setState(() {
      isLoading = false;
    });
    print('failed to login');
  }
}
