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

  Future<void> triggerRefresh() async {
    List<types.Room> chatRooms = [];
    List<String> chatRoomIds = chatRooms.map((e) => e.id).toList();
    for (final chatRoomId in widget.userState.currentUser!.chatRoomIds) {
      final chatRoom = await widget.userState.getStoredChatRoomByRoomId(chatRoomId);
      if (chatRoom != null && !chatRoomIds.contains(chatRoom.id)) {
        setState(() {
          chatRooms.add(chatRoom);
        });
      }
    }
    setState(() {
      this.chatRooms = chatRooms;
    });
  }

  void loadChatRooms() async {
    if (chatRooms.isEmpty) {
      setState(() {
        isLoadingChats = true;
      });
      triggerRefresh().then((value) => {
            setState(() {
              isLoadingChats = false;
            })
          });
    } else {
      List<String> chatRoomIds = chatRooms.map((e) => e.id).toList();
      for (final chatRoomId in widget.userState.currentUser!.chatRoomIds) {
        final chatRoom = await widget.userState.getStoredChatRoomByRoomId(chatRoomId);
        if (chatRoom != null && !chatRoomIds.contains(chatRoom.id)) {
          setState(() {
            chatRooms.add(chatRoom);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    chatRooms = widget.userState.storedChatRooms.values.toList();
    debugPrint(widget.userState.storedChatRooms.toString());
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => {
                            setState(() {
                              isLoadingChats = true;
                            }),
                            triggerRefresh().then((value) => {
                                  setState(() {
                                    isLoadingChats = false;
                                  })
                                })
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                          ),
                          iconSize: 48,
                        ),
                        const Text(
                          'No chats yet :(',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: triggerRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = chatRooms[index];
                      return buildItem(context, chatRoom);
                    },
                  ),
                ),
    );
  }

  String buildLastMessagePreview(List<types.Message>? lastMessages) {
    if (lastMessages != null && lastMessages.isNotEmpty) {
      final lastMessage = lastMessages.last;
      String authorFirstName;
      if (lastMessage.author.id == widget.userState.currentUser!.email) {
        authorFirstName = 'You';
      } else {
        authorFirstName = '${lastMessage.author.firstName!} ${lastMessage.author.lastName!.substring(0, 1)}';
      }

      String lastMessageText;
      if (lastMessage.type == types.MessageType.text) {
        lastMessageText = (lastMessage as types.TextMessage).text;
      } else {
        lastMessageText = '[Attachment]';
      }
      return '$authorFirstName: $lastMessageText';
    } else {
      return 'No messages yet';
    }
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
                    child: Text(buildLastMessagePreview(chatRoom.lastMessages),
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
