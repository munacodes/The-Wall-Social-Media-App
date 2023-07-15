import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment(
      {super.key, required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // comments
          Text(text),

          // user, time
          Row(
            children: [
              Text(user),
              const Text('.'),
              Text(time),
            ],
          ),
        ],
      ),
    );
  }
}
