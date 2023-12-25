import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/data/models/chat_user.dart';
import 'package:chat_box/helper/my_date_util.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.user.name),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(100)),
                      height: 155,
                      width: 155,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            height: 150,
                            width: 150,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(child: Icon(Icons.person)),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.user.email,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'About:  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: widget.user.about,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Joined on:  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: MyDateUtil.getLastMessageTime(
                                context: context,

                                ///This will give us a dummy year because first we will give a
                                ///microsecondSinceEpoch
                                ///Newly created account will give the original year
                                time: widget.user.createdAt,
                                showYear: true),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
