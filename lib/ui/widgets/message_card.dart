import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/api/apis.dart';
import 'package:chat_box/data/models/message.dart';
import 'package:chat_box/helper/my_date_util.dart';
import 'package:chat_box/helper/snack_message.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;

    return InkWell(
      onLongPress: () {
        _shoeBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    ///To update read time
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log('Message read updated');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 3 : 10),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) =>
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(Icons.person)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            MyDateUtil.getFormattedTime(
                context, widget.message.send.toString()),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [

            ///To add some space
            const SizedBox(
              width: 10,
            ),

            ///For showing double mark
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            ///To add some space
            const SizedBox(
              width: 4,
            ),

            ///To show the time when message send
            Text(
              MyDateUtil.getFormattedTime(context, widget.message.send),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 3 : 10),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),

            ///To show the message
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) =>
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(Icons.person)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //To show the modal bottom sheet
  void _shoeBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            //Black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery
                    .sizeOf(context)
                    .width * .03,
                horizontal: MediaQuery
                    .sizeOf(context)
                    .width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            widget.message.type == Type.text
                ? _OptionItem(
              icon: const Icon(
                Icons.copy,
                size: 26,
                color: Colors.blue,
              ),
              name: 'Copy Text',
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: widget.message.msg))
                    .then((value) {
                  //for hiding bottom sheet
                  Navigator.pop(context);

                  Dialogs.showMessage(context, 'Text Copied!');
                });
              },
            )
                : _OptionItem(
              icon: const Icon(
                Icons.download,
                size: 26,
                color: Colors.blue,
              ),
              name: 'Save Image',
              onTap: () async {
                //Have to implement image download option in latter
              },
            ),

            if (isMe)
              Divider(
                height: 1,
                color: Colors.black54,
                endIndent: MediaQuery
                    .sizeOf(context)
                    .width * .06,
                indent: MediaQuery
                    .sizeOf(context)
                    .width * .06,
              ),
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.edit_note,
                  size: 26,
                  color: Colors.green,
                ),
                name: 'Edit',
                onTap: () {
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                },
              ),
            if (isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.delete_forever,
                  size: 26,
                  color: Colors.red,
                ),
                name: 'Delete',
                onTap: () {
                  Navigator.pop(context);
                  APIs.deleteMessage(widget.message);
                },
              ),

            Divider(
              height: 1,
              color: Colors.black54,
              endIndent: MediaQuery
                  .sizeOf(context)
                  .width * .06,
              indent: MediaQuery
                  .sizeOf(context)
                  .width * .06,
            ),

            _OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                size: 26,
                color: Colors.blue,
              ),
              name: 'Send at:  ${MyDateUtil.getMessageTime(
                context: context,
                time: widget.message.send,
              )}',
              onTap: () {},
            ),
            _OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                size: 26,
                color: Colors.green,
              ),
              name: widget.message.read.isEmpty
                  ? 'Read at: Not seen yet'
                  : 'Read at: ${MyDateUtil.getMessageTime(
                context: context,
                time: widget.message.read,
              )}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 10,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery
            .sizeOf(context)
            .width * .06,
        vertical: MediaQuery
            .sizeOf(context)
            .height * .015,
      ),
      child: InkWell(
        onTap: () => onTap(),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '  $name',
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87, letterSpacing: .05),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
