import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatListScreen extends StatefulWidget {
  final UserState userState;
  const ChatListScreen({super.key, required this.userState});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<types.Room> chatRooms = [];
  bool isLoadingChats = false;

  void loadChatRooms() {
    setState(() {
      isLoadingChats = true;
    });
    widget.userState.fetchChatRooms().then((chatRooms) {
      setState(() {
        this.chatRooms = chatRooms;
        isLoadingChats = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoadingChats
          ? const Center(child: CircularProgressIndicator())
          : chatRooms.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    bottom: 200,
                  ),
                  child: const Text('No chats yet :('),
                )
              : ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    return ListTile(
                      title: Text(chatRoom.name!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(userState: widget.userState, room: chatRoom),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
