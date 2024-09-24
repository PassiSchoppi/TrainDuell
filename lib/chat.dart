import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {

  const Chat();

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  // Fetch latest chats from the server
  Future<void> fetchChats() async {
    final response = await http.get(Uri.parse('https://59x6pn8my4.execute-api.us-east-1.amazonaws.com/public/chat?chat_room_id=1'));

    if (response.statusCode == 200) {
      List<dynamic> chatData = jsonDecode(response.body);
      setState(() {
        messages = chatData.map((chat) => chat.toString()).toList();
        isLoading = false;
      });
    } else {
      // Handle server error
      setState(() {
        isLoading = false;
      });
    }
  }

  // Send message to the server
  Future<void> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('https://59x6pn8my4.execute-api.us-east-1.amazonaws.com/public/chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': message,
        'name': "Pascal",
        'chat_room_id': "1"
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchChats();
      });
      messageController.clear(); // Clear the input field
    } else {
      // Handle error
      print('Failed to send message.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Leander'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      sendMessage(messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
