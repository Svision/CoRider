import 'package:corider/providers/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final UserState userState;
  final types.Room room;
  const ChatScreen({Key? key, required this.userState, required this.room}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<types.Message> messages;

  @override
  void initState() {
    super.initState();
    messages = widget.room.lastMessages ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name!),
      ),
      body: Chat(
        messages: messages,
        onSendPressed: (types.PartialText message) {
          final newMessage = types.TextMessage(
            author: types.User(id: widget.userState.currentUser!.email),
            id: const Uuid().v4(),
            text: message.text,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );

          setState(() {
            messages.insert(0, newMessage);
          });
        },
        user: types.User(id: widget.userState.currentUser!.email),
      ),
    );
  }
}
