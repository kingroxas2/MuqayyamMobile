// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Prayer{
  String prayerName = "";
  DateTime prayerTime = DateTime.now();
  String prayerStatus = "false";
}

class TrackPrayer extends StatefulWidget {
  const TrackPrayer({Key? key}) : super(key: key);
  
  @override
  State<TrackPrayer> createState() => _TrackPrayerState();
}

// Future<void> logout(BuildContext context) async {
//   await FirebaseAuth.instance.signOut();
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => const LoginPage(),
//     ),
//   );
// }

class _TrackPrayerState extends State<TrackPrayer> with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isTimerRunning = false;
  int _timerSeconds = 0;
  final Duration animationDuration = Duration(seconds: 5);
  late Timer _nextPrayerTimer;

  Prayer subuh = Prayer()
                ..prayerName = "Subuh"
                ..prayerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 0,)
                ..prayerStatus = "false";

  Prayer syuruk = Prayer()
                ..prayerName = "Syuruk"
                ..prayerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 09)
                ..prayerStatus = "false";

  Prayer zuhur = Prayer()
                ..prayerName = "Zuhur"
                ..prayerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 19)
                ..prayerStatus = "false";

  Prayer asar = Prayer()
                ..prayerName = "Asar"
                ..prayerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16, 39)
                ..prayerStatus = "false";

  Prayer maghrib = Prayer()
                ..prayerName = "Maghrib"
                ..prayerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 19, 24)
                ..prayerStatus = "false";

  Prayer isyak = Prayer()
                ..prayerName = "Isyak"
                ..prayerTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 36,)
                ..prayerStatus = "false";

   @override
    void initState() {
    super.initState();
    setCurrentPrayer();
    checkForMissedPrayers();
    _animationController = AnimationController(
      vsync: this,
      duration: animationDuration, // Adjust the duration as needed
    );
    
    _nextPrayerTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Call setState to trigger a UI update
      setState(() {});
    });

      _animation = Tween<double>(begin: 0, end: animationDuration.inSeconds.toDouble())
      .animate(_animationController)
        ..addListener(() {
          setState(() {
            _timerSeconds = _animation.value.toInt();
          });

          if (_animation.isDismissed) {
            isTimerRunning = false;
            _stopTimer();
            performPrayer();
          }
        });
    }

  void _startTimer() {
  setState(() {
    _animationController.reverse(from: animationDuration.inSeconds.toDouble());
  });
}

  void _stopTimer() {
    setState(() {
      _animationController.stop();
    });
  }

  void setCurrentPrayer(){
    setState(() {
      String currentPrayerName = currentPrayer();
      List prayers = [subuh, syuruk, zuhur, asar, maghrib, isyak];
      prayers.firstWhere((prayer) => prayer.prayerName == currentPrayerName).prayerStatus = "current";
    });
  }

  String currentPrayer(){
  DateTime now = DateTime.now();
  if(now.isAfter(subuh.prayerTime) && now.isBefore(syuruk.prayerTime)){
    return "Subuh";
  }
  else if(now.isAfter(syuruk.prayerTime) && now.isBefore(zuhur.prayerTime)){
    return "Syuruk";
  }
  else if(now.isAfter(zuhur.prayerTime) && now.isBefore(asar.prayerTime)){
    return "Zuhur";
  }
  else if(now.isAfter(asar.prayerTime) && now.isBefore(maghrib.prayerTime)){
    return "Asar";
  }
  else if(now.isAfter(maghrib.prayerTime) && now.isBefore(isyak.prayerTime)){
    return "Maghrib";
  }
  else if(now.isAfter(isyak.prayerTime) || now.isBefore(subuh.prayerTime)){
    return "Isyak";
  }
  else {
    return "Syuruk";
  }
}

  String timeTillNextPrayer(String currentPrayer) {
  List<Prayer> prayers = [subuh, syuruk, zuhur, asar, maghrib, isyak];
  String displayText;
  
  int currentIndex = prayers.indexWhere((prayer) => prayer.prayerName == currentPrayer);
  Prayer nextPrayer = prayers[currentIndex];
  Duration timeRemaining;

  if (currentIndex >= 0 && currentIndex < prayers.length - 1) {
    nextPrayer = prayers[currentIndex + 1];
    if(currentPrayer == "Subuh"){
      nextPrayer = zuhur;
    }
  timeRemaining = nextPrayer.prayerTime.difference(DateTime.now());
  } 
  else {
    if(currentPrayer == "Isyak"){
      nextPrayer = subuh;
    }
    if(DateTime.now().isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59,))){//if before 11.59pm
    print("before 11.59pm");
      Duration midnightTillSubuh = nextPrayer.prayerTime.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00,));
      Duration nowTillMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59,).difference(DateTime.now());
      timeRemaining = midnightTillSubuh + nowTillMidnight;
      print('${DateTime.now()} \n${timeRemaining}');
      //print(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59,).difference(DateTime.now()));
    }
    else{
      print("after 11.59pm");
      timeRemaining = nextPrayer.prayerTime.difference(DateTime.now());
    }
  }

  int hours = timeRemaining.inHours;
  int minutes = timeRemaining.inMinutes.remainder(60);
  int seconds = timeRemaining.inSeconds.remainder(60);

   return hours>0 ? "Azan seterusnya dalam\n$hours jam, $minutes minit, $seconds saat" : "Azan seterusnya dalam\n$minutes minit, $seconds saat";
}


  void checkForMissedPrayers(){
    setState(() {
      List prayers = [subuh, syuruk, zuhur, asar, maghrib, isyak];

      for(int i=0; i<prayers.length; i++){
        if(prayers[i].prayerName == currentPrayer()){//if current prayer, break
        break;
        }
        if(prayers[i].prayerStatus != "current" && prayers[i].prayerStatus != "true"){
          prayers[i].prayerStatus = "missed";
        }
      }
      });
  }

  void performPrayer() {
    setState(() {
      String currentPrayer = this.currentPrayer();
    getCurrentPrayer(currentPrayer).prayerStatus = "true";
    checkForMissedPrayers();
    });
  }

  Prayer getCurrentPrayer(String currentPrayer){
    setState(() {
    });
    List<Prayer> prayers = [subuh, syuruk, zuhur, asar, maghrib, isyak];
    Prayer currentPrayerObj = prayers.firstWhere((prayer) => prayer.prayerName == currentPrayer);
    return currentPrayerObj;
  }

  String circleText() {
    List prayers = [subuh, syuruk, zuhur, asar, maghrib, isyak];
    int currentPrayerIndex = prayers.indexWhere((prayer) => prayer.prayerName == currentPrayer());
    
    if(prayers[currentPrayerIndex].prayerStatus == "true"){
      return timeTillNextPrayer(currentPrayer());
    }
    else if(isTimerRunning)
    {
      return displayMinute();
    }
    else{
      return "Mula solat ${currentPrayer()}";
    }
}
  IconData getPrayerIcon(String status) {
  switch (status) {
    case "true":
      return Icons.check_circle;
    case "missed":
      return Icons.cancel; // Missed (chosen icon for missed prayers)
    default:
      return Icons.check_circle; // Inactive (grey)
  }
}

  String displayMinute(){
    int minute = _timerSeconds ~/ 60;
    int second = _timerSeconds % 60;
    String minuteStr = minute.toString().padLeft(2, '0');
    String secondStr = second.toString().padLeft(2, '0');
    return '$minuteStr:$secondStr';
  }

  double calculateProgress() {
    return 1 - (_animation.value / animationDuration.inSeconds.toDouble());
  }

  @override
  void dispose() {
    _nextPrayerTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBEBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF82618B),
        title: const Text("Selamat pagi!"),
        actions: [
          IconButton(
            onPressed: () {
              //go to profile page
            },
            icon: const Icon(
              Icons.account_circle,
              size: 30,
            ),
          )
        ],
      ),
      //floating action button must be center
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigator.push(
            //context,
            //MaterialPageRoute(
              //builder: (context) =>
                  //CameraPage(cameraController: _cameraController),
            //),
          //);
        }, 
        backgroundColor: Color(0xFF82618B),
        child: const Icon(Icons.podcasts),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF82618B),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Updated alignment
            children: <Widget>[
              // Home
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackPrayer(),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                color: Colors.white,
              ),

              // Search (You can replace this with your desired search functionality)
              IconButton(
                onPressed: () {
                  // Add your search functionality here
                },
                icon: const Icon(Icons.search),
                color: Colors.white,
              ),

              // Trophy (You can replace this with your desired trophy functionality)
              IconButton(
                onPressed: () {
                  // Add your trophy functionality here
                },
                icon: const Icon(Icons.emoji_events),
                color: Colors.white,
              ),

              // Settings (You can replace this with your desired settings functionality)
              IconButton(
                onPressed: () {
                  // Add your settings functionality here
                },
                icon: const Icon(Icons.settings),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          GestureDetector(
          onTap: () {
            setState(() {
              isTimerRunning = !isTimerRunning;
              if (isTimerRunning) {
                _startTimer();
              } else {
                _stopTimer();
                if (!isTimerRunning) {
                  // Update the prayer status after finishing the current prayer
                  // performPrayer();
                }
              }
            });
          },
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF82618B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15), // Shadow color
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                children: [
                  Center(
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Text(
                          circleText(),
                          // isTimerRunning
                          //     ? displayMinute()
                          //     : "Mula solat ${currentPrayer()}",
                          style: TextStyle(fontSize: 25, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      height: 270,
                      width: 270,
                      child: CircularProgressIndicator(
                        value: isTimerRunning ? calculateProgress() : 0.0,
                        backgroundColor: Colors.white,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                        strokeWidth: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(25.0),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            getPrayerIcon(subuh.prayerStatus),
                            size: 32,
                            color : (subuh.prayerStatus == "true") ? Colors.green // Prayed (green)
                                  : (subuh.prayerStatus == "current") ? Colors.blue // Ongoing (blue)
                                  : (subuh.prayerStatus == "missed") ? Colors.red // Missed (red)
                                  : Colors.grey, // Inactive (grey)
                          ),
                          SizedBox(height: 3,),
                          Text("Subuh", style: TextStyle(fontSize: 12),),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                          getPrayerIcon(zuhur.prayerStatus),
                          size: 32, 
                          color : (zuhur.prayerStatus == "true")? Colors.green
                                : (zuhur.prayerStatus == "current") ? Colors.blue
                                : (zuhur.prayerStatus == "missed") ? Colors.red
                                : Colors.grey,
                          ),
                          SizedBox(height: 3,),
                          Text("Zohor", style: TextStyle(fontSize: 12),),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                          getPrayerIcon(asar.prayerStatus),
                          size: 32, 
                          color : (asar.prayerStatus == "true")? Colors.green
                                : (asar.prayerStatus == "current") ? Colors.blue
                                : (asar.prayerStatus == "missed") ? Colors.red
                                : Colors.grey,
                          ),
                          SizedBox(height: 3,),
                          Text("Asar", style: TextStyle(fontSize: 12),),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                          getPrayerIcon(maghrib.prayerStatus), 
                          size: 32, 
                          color : (maghrib.prayerStatus == "true")? Colors.green
                                : (maghrib.prayerStatus == "current") ? Colors.blue
                                : (maghrib.prayerStatus == "missed") ? Colors.red
                                : Colors.grey,
                          ),
                          SizedBox(height: 3,),
                          Text("Maghrib", style: TextStyle(fontSize: 12),),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                          getPrayerIcon(isyak.prayerStatus),
                          size: 32, 
                          color : (isyak.prayerStatus == "true")? Colors.green
                                : (isyak.prayerStatus == "current") ? Colors.blue
                                : (isyak.prayerStatus == "missed") ? Colors.red
                                : Colors.grey,
                          ),
                          SizedBox(height: 3,),
                          Text("Isyak", style: TextStyle(fontSize: 12),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
      )
    );
  }
}