import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController _postTextController = TextEditingController(text: '');

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String user_uid, user_display_name;
  File _image;

  /// Post to Firebase DB
  _post() async {
    if (_postTextController.text.trim().length == 0) {
      _key.currentState.showSnackBar(
        SnackBar(
          content: Text('Please enter some text to post.'),
        ),
      );

      return;
    }

    DocumentReference ref;

//model for posts
    try {


      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      ref = await _firestore.collection( user.displayName ).add({
        'text': _postTextController.text.trim(),
        'owner_name': user_display_name,
        'owner': user_uid,
        'created': DateTime.now(),
        'updated': true,
        'likes': {},
        'likes_count': 0,
        'comments_count': 0,
      });

      if(_image != null) {
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(
          SnackBar(
            content: Text('Uploading image, please wait ....'),
          ),
        );
        
        String _url = await _uploadImageAndGetURL(ref.documentID, _image);

        await ref.updateData({
          'image' : _url,
        });
      }

      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Post created successfully.'),
      ));

      /// Allows the user to see snackbar before navigating to feed page
      Future.delayed(
        Duration(seconds: 1),
        () {
          Navigator.pop(context);
        },
      );
    }
    catch (e) {
      print('Exception Thrown: $e');
      _key.currentState.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  _showModalBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  File image = await ImagePicker.pickImage(
                    source: ImageSource.camera,
                    maxHeight: 480,
                    maxWidth: 480,
                  );

                  setState(() {
                    _image = image;
                  });

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Photo Album'),
                onTap: () async {
                  File image = await ImagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxHeight: 480,
                    maxWidth: 480,
                  );

                  setState(() {
                    _image = image;
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<String> _uploadImageAndGetURL(String fileName, File file) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageUploadTask _task = _storage.ref().child(fileName).putFile(
          file,
          StorageMetadata(contentType: 'image/png'),
        );

    final String _downloadURL = await (await _task.onComplete).ref.getDownloadURL();

    return _downloadURL;
  }

  @override
  void initState() {
    super.initState();

    _firebaseAuth.currentUser().then((FirebaseUser user) {
      user_uid = user.uid;
      user_display_name = user.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Compose New Post'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.cyan,
              )),
              child: TextField(
                controller: _postTextController,
                maxLines: 5,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Write something here ...',
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      splashColor: Colors.cyan,
                      color: Colors.cyan,
                      onPressed: () {
                        _showModalBottomSheet();
                      },
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Add Image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      splashColor: Colors.cyan,
                      color: Colors.cyan,
                      onPressed: () {
                        _post();
                      },
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Create Post',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _image == null
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              child: Image.file(
                                _image,
                                fit: BoxFit.cover,
                              ),
                              width: 150,
                              height: 150,
                            ),
                            Positioned(
                              top: 4.0,
                              right: 4.0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                  });
                                },
                              ),
                            ),
                          ],
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
