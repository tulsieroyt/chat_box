import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_box/data/models/chat_user.dart';
import 'package:chat_box/ui/screens/login_screen.dart';
import 'package:chat_box/helper/snack_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/apis.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Your Profile'),
        ),
        floatingActionButton: ElevatedButton.icon(
            onPressed: () async {
              Dialogs.showProgressBar(context);

              ///For updating active status as false when user log out
              await APIs.updateActiveStatus(false);

              ///Calling logout api
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  ///For handling progress indicator
                  Navigator.pop(context);

                  ///To move home screen
                  Navigator.pop(context);

                  /// Check the firebase auth
                  APIs.auth = FirebaseAuth.instance;

                  ///Replacing home screen by login screen
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false);
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                  File(_image!),
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  height: 150,
                                  width: 150,
                                  imageUrl: widget.user.image.toString(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(Icons.person)),
                                  fit: BoxFit.fill,
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            onPressed: () {
                              _shoeBottomSheet();
                            },
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.user.email.toString(),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: TextFormField(
                          initialValue: widget.user.name,
                          onSaved: (val) => APIs.me.name = val ?? ' ',
                          validator: (val) => val != null && val.isNotEmpty
                              ? null
                              : 'Field required!',
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              label: const Text('Name'),
                              hintText: 'Your Name'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: TextFormField(
                          initialValue: widget.user.about,
                          onSaved: (val) => APIs.me.about = val ?? '',
                          validator: (val) => val != null && val.isNotEmpty
                              ? null
                              : 'Must drop you bio',
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.info_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              label: const Text('Bio'),
                              hintText: 'Your Bio'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showMessage(
                                context, 'Profile Update Successfully!');
                          });
                        }
                      },
                      child: const Text('Update'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shoeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SizedBox(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Pick Profile Picture',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ///Taking image using camera
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        _image = image.path;
                        setState(() {});
                      }
                      APIs.updateProfilePicture(File(_image!));
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset(
                      'assets/images/camera.png',
                      height: 50,
                    ),
                  ),

                  ///Taking image from gallery
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        _image = image.path;
                        setState(() {});
                      }
                      APIs.updateProfilePicture(File(_image!));
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset(
                      'assets/images/gallery.png',
                      height: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
