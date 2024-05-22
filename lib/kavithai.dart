import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:kavithaiquote/contact.dart';
import 'package:kavithaiquote/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;
  String _username = '';
  late String _email = '';
  File? _postImage;
  final picker = ImagePicker();
  int _currentIndex = 0;
  String? _postImageURL;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _postImage = null;
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchUserData();
      _loadPreferences();
    } else {
      // Handle the case where _user is null (not logged in)
      // Redirect to login screen or handle accordingly
    }
  }

  // Load preferences
  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _email = prefs.getString('email') ?? '';
      String avatarURL = prefs.getString('avatarURL') ?? '';
      if (avatarURL.isNotEmpty) {
        // Load the profile picture URL and display the image
        _postImageURL = avatarURL;
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5), // Adjust the duration as needed
      ),
    );
  }

  void _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(_user!.uid)
            .get();

        setState(() {
          String username = userSnapshot['username'];
          String email = userSnapshot['email'];

          _username = username;
          _email = email;
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _postImage = File(pickedFile.path);
        });

        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profilePictures/$imageName.jpg');
        UploadTask uploadTask = storageReference.putFile(_postImage!);
        await uploadTask.whenComplete(() async {
          String imageURL = await storageReference.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('user')
              .doc(_user?.uid)
              .update({
            'avatarURL': imageURL,
          });

          await _savePreferences(
              imageURL); // Save preferences after updating data

          // Reload preferences to refresh displayed picture
          Future.microtask(() => _loadPreferences());

          print('Profile picture uploaded successfully!');
        });
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

// Save preferences
  Future<void> _savePreferences(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _username);
    prefs.setString('email', _email);
    prefs.setString('avatarURL', imageUrl); // Save the profile picture URL
  }

  Future<void> reportPost(String postId, String imageURL) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageURL));
      final Uint8List imageBytes = response.bodyBytes;

      // Upload the reported post's image to the "reported posts" collection
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('reportedPosts/$imageName.jpg');
      UploadTask uploadTask = storageReference.putData(imageBytes);
      await uploadTask.whenComplete(() async {
        String reportedImageURL = await storageReference.getDownloadURL();

        // Save the reported post details in the "reported posts" collection
        await FirebaseFirestore.instance.collection('reportedPosts').add({
          'postId': postId,
          'reportedImageURL': reportedImageURL,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // You may want to notify the user that the post has been reported
        // or take any other necessary actions.
        print('Post reported successfully!');
        _showSnackBar('Post reported successfully Admin will take care!');
      });
    } catch (e) {
      print('Error reporting post: $e');
    }
  }

  Future<void> _uploadPost() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File postImage = File(pickedFile.path);

        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('posts/$imageName.jpg');
        UploadTask uploadTask = storageReference.putFile(postImage);
        await uploadTask.whenComplete(() async {
          String imageURL = await storageReference.getDownloadURL();

          // Assuming you have a 'posts' collection in Firestore
          await FirebaseFirestore.instance.collection('posts').add({
            'imageURL': imageURL,
            'username': _username, // Add logic to get username
            'userId': _user?.uid, // Include the user's UID
            'timestamp': FieldValue.serverTimestamp(),
          });

          print('Post uploaded successfully!');
        });
      }
    } catch (e) {
      print('Error uploading post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text(_currentIndex == 0 ? 'Profile' : 'Posts'),
        actions: [
          // Add a logout icon in the app bar
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout here
              _logout();
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu_open_sharp),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Builder(
        builder: (BuildContext context) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blueAccent,
                        child: ClipOval(
                          child: _postImageURL != null
                              ? Image.network(
                                  _postImageURL!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : (_postImage != null
                                  ? Image.file(
                                      _postImage!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: Colors.white,
                                    )),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _username, // Display user's username here
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        _email, // Display user's email here
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    // Handle profile navigation
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.attach_email_outlined,
                  ),
                  title: Text('Contact'),
                  onTap: () {
                    // Use Navigator.push to navigate to the contact screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        // The contact() function should not be called here directly
                        // Instead, you can create a new screen (e.g., ContactScreen) and navigate to it
                        return contact(); // Replace ContactScreen with the actual screen you want to navigate to
                      }),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {
                    // Handle logout
                    _logout();
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: _currentIndex == 0 ? buildProfileBody() : buildPostsBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.article),
            label: 'Posts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () async {
                await _uploadPost();
              },
              tooltip: 'Upload Post',
              child: Icon(Icons.add),
            ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Clear preferences on logout
      await _clearPreferences();

      // Navigate to the login or home page after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginScreen()), // Replace LoginPage with your login page
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

// Add the _clearPreferences method
  Future<void> _clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Widget buildProfileBody() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () async {
                await _uploadProfilePicture();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: ClipOval(
                      child: _postImageURL != null
                          ? Image.network(
                              _postImageURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : (_postImage != null
                              ? Image.file(
                                  _postImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.white,
                                )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Username: $_username',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Email: $_email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            SizedBox(height: 16),
            Container(
              height: 520, // Adjust the height as needed
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('userId', isEqualTo: _user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data?.docs.isEmpty ?? true) {
                    return Center(
                      child: Text('No posts available.'),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var post = snapshot.data!.docs[index];
                      var imageURL = post['imageURL'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          _showImageListDialog(snapshot.data!.docs);
                        },
                        child: Image.network(
                          imageURL,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageListDialog(List<QueryDocumentSnapshot> documents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 500,
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var post = documents[index];
                var imageURL = post['imageURL'] ?? '';
                var postId = post.id;

                return ListTile(
                  title: Stack(
                    children: [
                      Image.network(
                        imageURL,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(postId);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Image'),
          content: Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage(postId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage(String postId) async {
    try {
      // Delete the post document from Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      // Display a success message
      _showSnackBar('Post deleted successfully!');
    } catch (e) {
      print('Error deleting post: $e');
      // Display an error message if deletion fails
      _showSnackBar('Error deleting post. Please try again.');
    }
  }

  Widget buildPostsBody() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data?.docs.isEmpty ?? true) {
                return Center(
                  child: Text('No posts available.'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var post = snapshot.data!.docs[index];
                  var imageURL = post['imageURL'] ?? '';
                  var iconCount = (post.data() as Map<String, dynamic>)
                          .containsKey('iconCount')
                      ? (post.data() as Map<String, dynamic>)['iconCount']
                          as int?
                      : 0;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white38,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: _postImageURL != null
                                ? NetworkImage(_postImageURL!)
                                : AssetImage('assets/hi.png')
                                    as ImageProvider<Object>,
                          ),
                          title: Text(post['username']),
                          subtitle: Image.network(
                            imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            LikeButton(
                              postID: post.id,
                              userID: _user!.uid,
                              initialLiked: iconCount == 1,
                              onLiked: () {
                                // Handle the like action
                                // Update the iconCount in Firestore
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post.id)
                                    .update({
                                  'iconCount': FieldValue.increment(1),
                                });
                              },
                              onUnliked: () {
                                // Handle the unlike action
                                // Update the iconCount in Firestore
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(post.id)
                                    .update({
                                  'iconCount': FieldValue.increment(-1),
                                });
                              },
                            ),
                            Text('${iconCount ?? 0}'),
                            IconButton(
                              icon: Icon(Icons.report),
                              onPressed: () {
                                // Handle reporting post action
                                reportPost(post.id, imageURL);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class LikeButton extends StatefulWidget {
  final String postID;
  final String userID;
  final bool initialLiked;
  final VoidCallback? onLiked;
  final VoidCallback? onUnliked;

  const LikeButton({
    required this.postID,
    required this.userID,
    required this.initialLiked,
    this.onLiked,
    this.onUnliked,
    Key? key,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialLiked;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
      onPressed: () async {
        if (!isLiked) {
          // If not liked, add a like
          await FirebaseFirestore.instance.collection('likes').add({
            'postID': widget.postID,
            'userID': widget.userID,
          });

          if (widget.onLiked != null) {
            widget.onLiked!();
          }
        } else {
          // If liked, remove the like
          QuerySnapshot likeSnapshot = await FirebaseFirestore.instance
              .collection('likes')
              .where('postID', isEqualTo: widget.postID)
              .where('userID', isEqualTo: widget.userID)
              .get();

          for (QueryDocumentSnapshot likeDoc in likeSnapshot.docs) {
            await FirebaseFirestore.instance
                .collection('likes')
                .doc(likeDoc.id)
                .delete();
          }

          if (widget.onUnliked != null) {
            widget.onUnliked!();
          }
        }

        setState(() {
          isLiked = !isLiked;
        });
      },
    );
  }
}
