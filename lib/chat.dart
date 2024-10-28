import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {

  const Chat();

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, String>> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  // Fetch latest chats from the server
  Future<void> fetchChats() async {
    final response = await http.get(Uri.parse('https://gbn3noq85h.execute-api.us-east-1.amazonaws.com/prod?chat_room_id=3'));

    if (response.statusCode == 200) {
      List<dynamic> chatData = jsonDecode(response.body);
      setState(() {
        messages = chatData.map((chat) {
          try {
            if(chat == null) {
              return{
                'sender': '---',
                'message': '---',
                'time': '---'
              };
            }

            // print(json.decode(chat));
            var message = json.decode(chat.toString())[0];

            final timestampString = json.decode(chat.toString())[1]
                .toString(); // Timestamp after the last comma
            final timestamp = double.tryParse(timestampString) ?? 0;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(
                (timestamp * 1000).toInt());
            final formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:"
                "${dateTime.minute.toString().padLeft(2, '0')}:"
                "${dateTime.second.toString().padLeft(2, '0')}";

            return {
              'sender': message['name'].toString(),
              'message': message['message'].toString(),
              'time': formattedTime,
            };
          } catch (e) {
            return{
              'sender': '---',
              'message': '---',
              'time': '---'
            };
          }

        }).toList();
        isLoading = false;
      });
    } else {
      // Handle server error
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build chat bubble based on the sender
  Widget buildChatBubble(Map<String, String> chat) {
    bool isMe = chat['sender'] == 'Leander';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              chat['sender']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              chat['message']!,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            Text(
              chat['time']!,
              style: TextStyle(
                color: isMe ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Send message to the server
  Future<void> sendMessage(String message) async {
    var data = {
      'message': message,
      'name': "Pascal"
    };
    var stringified_message = jsonEncode(data);
    var message_json = {
      'message': stringified_message,
      'chat_room_id': "3"
    };
    final response = await http.post(
      Uri.parse('https://gbn3noq85h.execute-api.us-east-1.amazonaws.com/prod'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(message_json),
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
        title: Text('Chat with Pascal'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildChatBubble(messages[index]);
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
