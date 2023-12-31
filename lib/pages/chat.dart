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

  @override
  void initState() {
    super.initState();
    // Call setReadMessages when the chat room is opened to mark messages as read
    print("printing unread messages");
    _setMessagesAsRead();
  }

  Future<void> _setMessagesAsRead() async {
    try {
      // Call setReadMessages with the appropriate chat room ID
      await _chatService.setReadMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid);
    } catch (e) {
      print('Error setting messages as read: $e');
    }
  }

  void sendMessage() async {
    if(_messageController.text.isNotEmpty){
      String message = _messageController.text;
      _messageController.clear();
      await _chatService.sendMessage(widget.receiverUserID, message);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    
  //QuerySnapshot <Map <String, dynamic>> userDoc = firestore.collection("users").where('userID',isEqualTo:widget.userID).get() as QuerySnapshot<Map<String,dynamic>>;  
  //String userName = userDoc.get('name').toString();
    return Scaffold(
      backgroundColor: Color(0xFFEBEBEB),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF82618B),
        title: Align(
          alignment: Alignment.centerLeft,
          child: 
              Text(widget.receiverUserName, style: const TextStyle(color: Colors.white)),
          ),
        ),
      // Rest of your content here
      body: Column(
        children: [
          const SizedBox(height: 20,),
          Expanded(
            child: _buildMessageList(),
            ),

          _buildMessageInput(),
        ],
      ),
    );
  }

ScrollController _scrollController = ScrollController();

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll to the bottom when the data is loaded
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      return ListView.builder(
         controller: _scrollController, // Attach the ScrollController here
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
          final document = snapshot.data!.docs[index];
          return _buildMessageItem(document);
        },
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
                  ? (data['read'] == true) ? Color.fromARGB(255, 150, 123, 182) : Color.fromARGB(255, 150, 157, 219)
                  : const Color.fromARGB(255, 207, 207, 207),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(data['message'], 
            style: TextStyle(
              color: (data['senderId'] == _firebaseAuth.currentUser?.uid)
              ? Colors.white
              : Colors.black ),)),
        ],
      ),
    ),
  );
}

    Widget _buildMessageInput(){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: MyTextField(
                controller: _messageController,
                hintText: "Mesej anda",
                maxLines: 5,
                obscureText: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF82618B),
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.arrow_upward, size: 21, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }
}
