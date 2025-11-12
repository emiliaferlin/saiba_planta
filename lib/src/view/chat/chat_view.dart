import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatViewState();
  }
}

class ChatViewState extends State<ChatView> {
  TextEditingController textController = TextEditingController();
  ImagePicker picker = ImagePicker();
  bool isComposing = false;
  bool isLoading = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference mensagens = FirebaseFirestore.instance.collection(
      'mensagens',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser != null ? 'Olá, ${currentUser?.email}' : 'Chat',
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: mensagens.orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs.reversed.toList() ?? [];

                return ListView.builder(
                  itemCount: documents.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        bottom: 4.0,
                      ),
                      child: displayMsg(
                        context,
                        documents[index],
                        documents[index].get("uid") == currentUser?.uid,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          isLoading == true ? const LinearProgressIndicator() : composer(),
        ],
      ),
    );
  }

  Widget composer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.cyan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () async {
                try {
                  final img = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (img != null) {
                    _sendMessage(imgFile: img);
                  }
                } catch (e) {
                  debugPrint("Erro ao abrir câmera: $e");
                }
              },
            ),
            Expanded(
              child: TextField(
                controller: textController,
                decoration: const InputDecoration.collapsed(
                  hintText: "Enviar uma mensagem",
                ),
                onChanged: (text) {
                  setState(() {
                    isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: (text) {
                  _sendMessage(text: text);
                  _reset();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed:
                  isComposing
                      ? () {
                        _sendMessage(text: textController.text);
                        _reset();
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    textController.clear();
    setState(() {
      isComposing = false;
    });
  }

  Future<void> _sendMessage({String? text, XFile? imgFile}) async {
    final CollectionReference mensagens = FirebaseFirestore.instance.collection(
      'mensagens',
    );

    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      'time': Timestamp.now(),
      'url': '',
      'text': '',
      'uid': currentUser?.uid,
      'senderName': currentUser?.email,
      'senderPhotoUrl': currentUser?.photoURL ?? '',
    };

    if (imgFile != null) {
      data['url'] = await _upload(imgFile);
    } else if (text != null && text.isNotEmpty) {
      data['text'] = text;
    }

    await mensagens.add(data);

    setState(() {
      isLoading = false;
    });
  }

  Widget displayMsg(
    BuildContext context,
    DocumentSnapshot<Object?> data,
    bool mine,
  ) {
    final photoUrl = data.get('senderPhotoUrl') ?? '';
    final msgImageUrl = data.get('url') ?? '';
    final msgText = data.get('text') ?? '';
    final senderName = data.get('senderName') ?? 'Desconhecido';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          // Avatar do outro usuário
          if (!mine)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              ),
            ),

          // Mensagem
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                msgImageUrl.isNotEmpty
                    ? Image.network(
                      msgImageUrl,
                      width: 150,
                      errorBuilder:
                          (_, __, ___) => const Icon(Icons.broken_image),
                    )
                    : Text(msgText, style: const TextStyle(fontSize: 16)),
                Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Avatar do próprio usuário
          if (mine)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              ),
            ),
        ],
      ),
    );
  }

  Future<String> _upload(XFile imgFile) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("imgs")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

      final metadata = firebase_storage.SettableMetadata(
        contentType: "image/jpeg",
      );

      firebase_storage.UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(await imgFile.readAsBytes(), metadata);
      } else {
        uploadTask = ref.putFile(File(imgFile.path), metadata);
      }

      final snapshot = await uploadTask.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint("Erro no upload: $e");
      return "";
    }
  }
}
