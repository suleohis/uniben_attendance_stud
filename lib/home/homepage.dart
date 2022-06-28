import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniben_attendance_stud/auth/loginpage.dart';
import 'package:uniben_attendance_stud/home/api_requests.dart';
import 'package:uniben_attendance_stud/home/profile.dart';
import 'package:uniben_attendance_stud/models/Student.dart';
import 'package:uniben_attendance_stud/models/lecture.dart';
import 'package:uniben_attendance_stud/onboardingpage.dart';

Student? user;

class HomePage extends StatefulWidget {
  final List<Lecture>? lectures;
  HomePage(this.lectures);
  @override
  _HomePageState createState() => _HomePageState(lectures);
}

class _HomePageState extends State<HomePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  List<Lecture>? lectures = [];
  _HomePageState(this.lectures);

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUserLoginStatus();
  }

  ///This function checks whether the user is logged in
  ///or its the first time the user is launching the app
  ///if this is the first time the user is logged in, the user
  ///is sent to the onboarding page, its not, but the user is
  ///still not logged in, the user is sent to the sign in page
  ///if the user is logged in, the user remains on the homepage

  bool isLoading = true;
  checkUserLoginStatus() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      bool firstTime = prefs.getBool('is_first_time') ?? true;
      if (firstTime) {
        // navigate to the onboarding page
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => OnboardingPage()));
        prefs.setBool('is_first_time', false);
      } else {
        // check if the user is logged in
        if (prefs.getBool('logged_in') ?? false) {
          String? firstname = prefs.getString('firstname');
          String? lastname = prefs.getString('lastname');
          String? email = prefs.getString('email');

          user = Student(
              firstname: firstname!, lastname: lastname!, email: email!);

          setState(() {
            isLoading = false;
          });

          if (lectures == null) {
            lectures = [];
            dynamic result = await getLectures();
            setState(() {
              isLoading = false;
            });
            if (result is Map) {
              if (result['status'] == 'ok') {
                setState(() {
                  gLectures = result['lectures'];
                });
                print(gLectures);
              } else {
                // This is an error
                print(result);
              }
            } else {
              print(result);
            }
          }

          // get user data from api using data in shared preferences also
          // store most basic data for homepage in sharedPreferences
          // then fetch extra data for other areas as needed
        } else {
          // navigate to login page
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const Login()));
        }
      }
    });
  }

  bool showScanner = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: isLoading
            ? const Center(child: CircularProgressIndicator())
            : DefaultTabController(
                length: 2,
                child: Scaffold(
                    appBar: AppBar(
                       title: Text(
                          'Hi ${user!.firstname! + ' ' + user!.lastname!},'),
                      bottom: const TabBar(
                        tabs: [
                          Tab(
                              icon: Icon(Icons.qr_code_rounded),
                              text: 'Attend Lecture'),
                          Tab(icon: Icon(Icons.list), text: 'Lectures Attended')
                        ],
                      ),
                      actions: [
                        IconButton(
                            icon: const Icon(Icons.person,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const Profile()));
                            })
                      ],
                    ),
                    body: TabBarView(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: showScanner
                                        ? QRView(
                                            key: qrKey,
                                            onQRViewCreated: _onQRViewCreated,
                                          )
                                        : Icon(
                                            Icons.qr_code_scanner,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.4,
                                            color: Colors.grey,
                                          )),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        !showScanner
                                            ? Container(
                                                height: 50,
                                                margin: const EdgeInsets.only(
                                                    top: 12),
                                                child: Material(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  elevation: 4,
                                                  color: Colors.amber,
                                                  child: InkWell(
                                                      splashColor: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      onTap: () {
                                                        setState(() {
                                                          showScanner = true;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.2,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                                'Tap to Scan'
                                                                    .toUpperCase(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18)),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 6),
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .camera_alt_outlined,
                                                              size: 40,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        )),
                                                      )),
                                                ))
                                            : const SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                        showScanner
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.2,
                                                margin: const EdgeInsets.only(
                                                    top: 12),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                        height: 50,
                                                        margin: const EdgeInsets
                                                                .only(
                                                            left: 8, right: 8),
                                                        width: 100,
                                                        child: Material(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          elevation: 4,
                                                          color: Colors.grey,
                                                          child: InkWell(
                                                              splashColor:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              onTap: () async {
                                                                await controller!
                                                                    .flipCamera();
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    1.2,
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                                child: Center(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: const [
                                                                    Icon(
                                                                      Icons
                                                                          .flip_camera_android,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ],
                                                                )),
                                                              )),
                                                        )),
                                                    Container(
                                                        height: 50,
                                                        margin: const EdgeInsets
                                                                .only(
                                                            left: 8, right: 8),
                                                        width: 200,
                                                        child: Material(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          elevation: 4,
                                                          color: Colors.red,
                                                          child: InkWell(
                                                              splashColor:
                                                                  Colors.green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              onTap: () {
                                                                setState(() {
                                                                  showScanner =
                                                                      false;
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 50,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                                child: Center(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                        'CANCEL'
                                                                            .toUpperCase(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 18)),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              6),
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .cancel_presentation,
                                                                      size: 40,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ],
                                                                )),
                                                              )),
                                                        ))
                                                  ],
                                                ))
                                            : const SizedBox(
                                                height: 0,
                                                width: 0,
                                              )
                                      ],
                                    )),
                              ],
                            )),

                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('students')
                                        .doc(auth.currentUser!.uid)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        DocumentSnapshot docSna =
                                            snapshot.data!;
                                        List<dynamic> map =
                                            docSna['lectures_attend'];
                                        return ListView.builder(
                                          itemCount: map.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(
                                                  map[index]['course_code']),
                                              subtitle: Text(
                                                  map[index]['course_name']),
                                              trailing: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    DateFormat.yMEd()
                                                        .add_jms()
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                map[index][
                                                                    'createdAt'])),
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('${snapshot.error}');
                                      }
                                      if (!snapshot.hasData) {
                                        return Center(
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                ),
                                                child: const Text(
                                                    'You have not attended any lectures yet',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle())));
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                        // gLectures.isEmpty ? Center(
                        //   child: Container(
                        //     margin: const EdgeInsets.only(left: 16, right: 16),
                        //     child: const Text('You have not attended any lectures yet')
                        //   )
                        // ) :
                        // ListView.builder(
                        //   itemCount: gLectures.length,
                        //   itemBuilder: (context, index) {
                        //     return ListTile(
                        //       title: Text(gLectures[index].courseCode),
                        //       subtitle: Text(gLectures[index].courseName == null
                        //           ? 'Test'
                        //           : gLectures[index].courseName),
                        //       trailing: Column(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Text(
                        //               '${DateFormat.yMEd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(int.parse(gLectures[index].createdAt)))}',
                        //           style: const TextStyle(fontSize: 12),),
                        //           Row(
                        //             mainAxisSize: MainAxisSize.min,
                        //             children: [
                        //               const Icon(
                        //                 Icons.group,
                        //                 color: Colors.green,
                        //               ),
                        //               Container(
                        //                 margin: const EdgeInsets.only(left: 8),
                        //               ),
                        //               // Text('${snapshot.data[index].attendees.length}')
                        //             ],
                        //           )
                        //         ],
                        //       ),
                        //       onTap: () {
                        //         //print(snapshot.data[index].attendees[0]['student_id']);
                        //         //Navigator.of(context).push(MaterialPageRoute(builder: (_)=> LectureAttendees(attendees: snapshot.data[index].attendees)));
                        //       },
                        //     );
                        //   },
                        // )
                      ],
                    ))));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      print(result?.code);
      attendLecture(result?.code);
      controller.stopCamera();
      setState(() {
        showScanner = false;
      });
      // setState(() {
      //   result = scanData;
      //
      //   //print('Barcode Type: ${describeEnum(result?.format)}   Data: ${result?.code}');
      // });
    });
  }

  List<Lecture> gLectures = [];
  attendLecture(lectureToken) async {
    setState(() {
      isLoading = true;
    });
    dynamic result = await attendLectureRequest(lectureToken, context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}
