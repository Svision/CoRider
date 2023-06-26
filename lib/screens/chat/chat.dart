import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/providers/user_state.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final UserState userState;
  final types.Room room;
  const ChatScreen({Key? key, required this.userState, required this.room}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot>? _messagesStream;
  late List<types.Message> _messages;
  late User _user;

  void _loadMockMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages =
        (jsonDecode(response) as List).map((e) => types.Message.fromJson(e as Map<String, dynamic>)).toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.userState.currentUser!.companyName)
        .collection('chatRooms')
        .doc(widget.room.id)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
    _user = widget.userState.currentUser!.toChatUser();
    _messages = widget.room.lastMessages ?? [];
  }

  Future<void> _sendMessage(types.Message message) async {
    setState(() {
      _messages.insert(0, message);
    });
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.userState.currentUser!.companyName)
          .collection('chatRooms')
          .doc(widget.room.id)
          .collection('messages');
      final messageData = message.toJson();
      await messagesRef.add(messageData);
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Revert optimistic update
      setState(() {
        _messages.remove(message);
      });
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user, // only store user id in database
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _sendMessage(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name!),
      ),
      body: _messagesStream == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data?.docs.map((doc) {
                  final messageData = doc.data() as Map<String, dynamic>;
                  return types.Message.fromJson(messageData);
                }).toList();
                _messages = messages ?? [];
                _messages = _fetchUsersByMessages(_messages);

                return Chat(
                  messages: _messages,
                  onAttachmentPressed: _handleAttachmentPressed,
                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  onSendPressed: _handleSendPressed,
                  showUserAvatars: true,
                  showUserNames: true,
                  timeFormat: DateFormat('h:mm a'),
                  user: _user,
                );
              },
            ),
    );
  }

  types.Message _fetchUserByMessage(types.Message message) {
    if (widget.userState.storedUsers.containsKey(message.author.id)) {
      final user = widget.userState.storedUsers[message.author.id];
      message = message.copyWith(author: user!.toChatUser());
    } else {
      // store user for future use
      widget.userState.getStoredUserByEmail(message.author.id);
    }
    return message;
  }

  List<types.Message> _fetchUsersByMessages(List<types.Message> messages) {
    return messages.map((message) => _fetchUserByMessage(message)).toList();
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final placeholderMessage = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );
      setState(() {
        _messages.insert(0, placeholderMessage);
      });

      try {
        // upload file to storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_files')
            .child(widget.userState.currentUser!.companyName)
            .child(widget.room.id);

        // handle same file names
        bool hasDuplicate;
        try {
          await storageRef.child(result.files.single.name).getMetadata();
          hasDuplicate = true;
        } catch (e) {
          hasDuplicate = false;
        }
        if (hasDuplicate) {
          final String fileName = result.files.single.name;
          final String extension = fileName.substring(fileName.lastIndexOf('.'));
          final String fileNameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
          final String newFileName = '${fileNameWithoutExtension}_${DateTime.now().millisecondsSinceEpoch}$extension';
          storageRef = storageRef.child(newFileName);
        } else {
          storageRef = storageRef.child(result.files.single.name);
        }

        final uploadTask = storageRef.putFile(
          File(result.files.single.path!),
          SettableMetadata(
            contentType: lookupMimeType(result.files.single.path!),
          ),
        );
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // update message with uploaded file url
        types.FileMessage message = placeholderMessage.copyWith(uri: downloadUrl) as types.FileMessage;

        // remove placeholder
        _messages.remove(placeholderMessage);
        _sendMessage(message);
      } catch (e) {
        debugPrint('Error sending message: $e');
        // Revert optimistic update
        setState(() {
          _messages.remove(placeholderMessage);
        });
        return;
      }
    }
  }

  Future<void> _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      // add placeholder to show image before uploading
      final placeholderMessage = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
      setState(() {
        _messages.insert(0, placeholderMessage);
      });

      try {
        // upload image to storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child(widget.userState.currentUser!.companyName)
            .child(widget.room.id)
            .child(result.name);

        final uploadTask = storageRef.putData(bytes);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // update message with uploaded image url
        types.ImageMessage message = placeholderMessage.copyWith(uri: downloadUrl) as types.ImageMessage;

        // remove placeholder
        _messages.remove(placeholderMessage);
        _sendMessage(message);
      } catch (e) {
        setState(() {
          _messages.remove(placeholderMessage);
        });
        debugPrint('Error sending image: $e');
        return;
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index = _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage = (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index = _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage = (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }
}
