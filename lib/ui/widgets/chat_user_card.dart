import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/api/apis.dart';
import 'package:chat_box/data/models/chat_user.dart';
import 'package:chat_box/data/models/message.dart';
import 'package:chat_box/helper/my_date_util.dart';
import 'package:chat_box/ui/screens/chat_screen.dart';
import 'package:chat_box/ui/widgets/profile_dialog.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                user: widget.user,
              ),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              leading: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => ProfileDialog(user: widget.user));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    height: 40,
                    width: 40,
                    imageUrl: widget.user.image.toString(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(Icons.person)),
                  ),
                ),
              ),

              ///To shoe the user name
              title: Text(widget.user.name.toString()),

              ///To show the user last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: _message == null
                  ? null //show nothing when no message is sent
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ?
                      //show for unread message
                      Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      :
                      //message sent time
                      Text(
                          MyDateUtil.getLastMessageTime(
                              context: context, time: _message!.send),
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
            );
          },
        ),
      ),
    );
  }
}
