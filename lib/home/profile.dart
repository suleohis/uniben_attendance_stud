import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniben_attendance_stud/home/api_requests.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs){
      firstnameController.text = prefs.getString('firstname');
      lastnameController.text = prefs.getString('lastname');
      emailController.text = prefs.getString('email');
    });

  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            TextButton(
              child: Text('Done', style: TextStyle(color: Colors.white),),
              onPressed: (){
                // save edited data
                setState(() {
                  loading = true;
                });
                editProfile(firstnameController.text, lastnameController.text).then((val){
                  if(val == 'ok'){
                    setState(() {
                      loading = false;
                    });
                    Navigator.of(context).pop();
                  }else{
                    setState(() {
                      loading = false;
                    });
                  }
                });
              },
            )
          ],
          title: Text('Edit Student Profile'),
          automaticallyImplyLeading: false,
          leading: BackButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
      ),
      body: loading ? Center(child: CircularProgressIndicator()) : Container(
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            Container(
              height: 50,
              child: TextField(
                controller: firstnameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'First name'
                ),
              )
            ),

            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Container(
                  height: 50,
                  child: TextField(
                    controller: lastnameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Last name'
                    ),
                  )
              )
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    child: Text('Change Password'),
                    onPressed: (){
                      // change password
                    },
                  )
              ),
            )


          ],
        )
      )
    );
  }
}
