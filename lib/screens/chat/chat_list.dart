import 'package:cached_network_image/cached_network_image.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/chat/chat.dart';
import 'package:corider/screens/chat/extensions.dart';
import 'package:corider/utils/utils.dart';
import 'package:corider/widgets/notification_badge.dart';
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
  int _totalNotifications = 0;

  Future<void> triggerRefresh() async {
    await widget.userState.fetchAllChatRooms();
    setState(() {
      chatRooms = widget.userState.storedChatRooms.values.toList().sortedRooms();
    });
  }

  void loadChatRooms() async {
    if (chatRooms.isEmpty) {
      setState(() {
        isLoadingChats = true;
      });
      await triggerRefresh();
      setState(() {
        isLoadingChats = false;
      });
    } else {
      await triggerRefresh();
    }
  }

  @override
  void initState() {
    super.initState();
    chatRooms = widget.userState.storedChatRooms.values.toList().sortedRooms();
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
      final lastMessage = lastMessages.first;
      String authorFirstName;
      if (lastMessage.author.id == widget.userState.currentUser!.email) {
        authorFirstName = 'You';
      } else {
        authorFirstName =
            '${lastMessage.author.firstName ?? 'Unknown'} ${lastMessage.author.lastName?.substring(0, 1)}';
      }

      String lastMessageText;
      if (lastMessage.type == types.MessageType.text) {
        lastMessageText = (lastMessage as types.TextMessage).text;
      } else {
        lastMessageText = '[Attachment]';
      }
      return lastMessage.author.id == 'notifications' ? lastMessageText : '$authorFirstName: $lastMessageText';
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
              padding: const EdgeInsets.only(left: 15),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Utils.getUserAvatarNameColor(chatRoom.id),
                      child: chatRoom.imageUrl == null
                          ? Icon(
                              chatRoom.type == types.RoomType.group
                                  ? Icons.group
                                  : chatRoom.type == types.RoomType.channel
                                      ? Icons.message
                                      : Icons.person,
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
                  Positioned(
                    top: 0,
                    right: _totalNotifications > 9 ? 0 : 5,
                    child: NotificationBadge(
                      totalNotifications: _totalNotifications,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(chatRoom.name ?? 'Loading...',
                            maxLines: 1, style: TextStyle(color: Utils.getUserAvatarNameColor(chatRoom.id))),
                        if (chatRoom.lastMessages?.first != null)
                          Text(
                              DateTime.fromMillisecondsSinceEpoch(chatRoom.lastMessages!.first.createdAt!)
                                  .getFormattedString(),
                              maxLines: 1,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
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
