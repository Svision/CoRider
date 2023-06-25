import 'package:cached_network_image/cached_network_image.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatListScreen extends StatefulWidget {
  final UserState userState;

  const ChatListScreen({Key? key, required this.userState}) : super(key: key);

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
        title: const Text(
          'Chats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  margin: const EdgeInsets.only(bottom: 200),
                  child: const Text(
                    'No chats yet :(',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    return buildItem(context, chatRoom);
                  },
                ),
    );
  }

  Widget buildItem(BuildContext context, types.Room chatRoom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userState: widget.userState,
                room: chatRoom,
              ),
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[300]!),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CircleAvatar(
                maxRadius: 30,
                backgroundColor: chatRoom.imageUrl == null ? Colors.grey : null,
                child: chatRoom.imageUrl == null
                    ? chatRoom.type == types.RoomType.group
                        ? const Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 30,
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          )
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: chatRoom.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
              ),
            ),
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      chatRoom.name!,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        chatRoom.lastMessages == null || chatRoom.lastMessages!.isEmpty
                            ? 'No messages yet'
                            : chatRoom.lastMessages![-1].author.id == widget.userState.currentUser!.email
                                ? 'You: '
                                : chatRoom.type == types.RoomType.group
                                    ? '${chatRoom.lastMessages![-1].author.firstName}: '
                                    : ''
                                        '${chatRoom.lastMessages![-1].type == types.MessageType.text ? (chatRoom.lastMessages![-1] as types.TextMessage).text : '[Attachment]'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
