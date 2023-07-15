import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall_social_media_app/widgets/widget_export.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false;

  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser!.email);
  }

  // toggle like
  void toggled() {
    setState(() {
      isLiked = !isLiked;
    });

    // Access the document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked, add the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser!.email])
      });
    } else {
      // if the post is now unliked, remove the user's email from the 'likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser!.email])
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    // write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser!.email,
      "CommentTime": Timestamp.now(), // remeber to format this when displaying
    });
  }

  // show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: 'Write a comment..'),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //  clear controller
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),

          // Post button
          TextButton(
            onPressed: () {
              // add comment
              addComment(_commentTextController.text);

              //pop box
              Navigator.pop(context);

              //  clear controller
              _commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // wallpost
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // message
              Text(widget.message),

              const SizedBox(height: 10),

              // user
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // like
              Column(
                children: [
                  // like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggled,
                  ),

                  const SizedBox(height: 5),

                  // like count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // Comment
              Column(
                children: [
                  // Comment button
                  CommentButton(onTap: showCommentDialog),

                  const SizedBox(height: 5),

                  // Comment count
                  const Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          // Comments under the post
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .doc(widget.postId)
                .collection('Comments')
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true, // for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map<Widget>((doc) {
                  // get the comment
                  final commentData = doc.data();

                  // return the comments
                  return Comment(
                    text: commentData['CommentText'],
                    user: commentData['CommentedBy'],
                    time: commentData['CommentTime'],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
