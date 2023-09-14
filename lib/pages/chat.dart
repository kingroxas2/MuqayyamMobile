import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wildlifego/components/my_text_field.dart';
import 'package:wildlifego/services/chat_service.dart';
import '../firebase/firebase_config.dart';

class Chat extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserEmail;
  final String receiverUserID;
  const Chat({Key? key, required this.receiverUserName, required this.receiverUserEmail, required this.receiverUserID}) : super(key: key);
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  FirebaseFirestore firestore = FirebaseConfig.firestore;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if(_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
      //clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    
  //QuerySnapshot <Map <String, dynamic>> userDoc = firestore.collection("users").where('userID',isEqualTo:widget.userID).get() as QuerySnapshot<Map<String,dynamic>>;  
  //String userName = userDoc.get('name').toString();
    return Scaffold(
      backgroundColor: Color(0xFFEBEBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF82618B),
        title: Align(
          alignment: Alignment.centerLeft,
          child: 
              Text(widget.receiverUserName),
          ),
        ),
      // Rest of your content here
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: _buildMessageList(),
            ),

          _buildMessageInput(),
        ],
      ),
    );
  }

Widget _buildMessageList(){
  return StreamBuilder(stream: _chatService.getMessages(
    widget.receiverUserID, _firebaseAuth.currentUser!.uid),
    builder: (context, snapshot) {
      if(snapshot.hasError){
        return Text("Error ${snapshot.error}");
      }

      if(snapshot.connectionState == ConnectionState.waiting){
        return const Text("Loading...");
      }

      return ListView(
        children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
    }

    Widget _buildMessageItem(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  var alignment = (data['senderId'] == _firebaseAuth.currentUser?.uid)
      ? Alignment.centerRight
      : Alignment.centerLeft;

  return Container(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser?.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser?.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          //Text(data['senderEmail']),
          Container(
            decoration: BoxDecoration(
              color: (data['senderId'] == _firebaseAuth.currentUser?.uid)
                  ? Colors.blue
                  : Colors.grey[500],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(data['message'], style: const TextStyle(color: Colors.white),)),
        ],
      ),
    ),
  );
}


    Widget _buildMessageInput(){
      return Row(
        children: [
          Expanded(
            child: MyTextField(
            controller: _messageController,
            hintText: "Mesej anda",
            obscureText: false,
            ),
            ),

            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue,
              child: IconButton(onPressed: sendMessage, 
            icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white,)),
            )
            
        ],
      );
    }
}