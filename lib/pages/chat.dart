import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_config.dart';

class Chat extends StatefulWidget {
  final String userID;
  const Chat({Key? key, required this.userID}) : super(key: key);
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  FirebaseFirestore firestore = FirebaseConfig.firestore;

  @override
  Widget build(BuildContext context) {
    
  //QuerySnapshot <Map <String, dynamic>> userDoc = firestore.collection("users").where('userID',isEqualTo:widget.userID).get() as QuerySnapshot<Map<String,dynamic>>;  
  //String userName = userDoc.get('name').toString();
    return Scaffold(
      backgroundColor: Color(0xFFEBEBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF82618B),
        title: Text("Bual dengan ${widget.userID}"),
        actions: [
          IconButton(
            onPressed: () {
              // Go to profile page
            },
            icon: const Icon(
              Icons.account_circle,
              size: 30,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB tap
        },
        backgroundColor: Color(0xFF82618B),
        child: const Icon(Icons.podcasts),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(
        color: Color(0xFF82618B),
        shape: CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Navigation buttons here
            ],
          ),
        ),
      ),
      // Rest of your content here
      body: Center(
        child: Text('Bual dengan ${widget.userID}'),
        // ...
      ),
    );
  }
}