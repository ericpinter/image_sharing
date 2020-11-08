import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_sharing/send.dart';
import './post.dart';

class FeedTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<Post> posts = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Hero(

            tag: "post",
            child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SendTab())),
                child: Text("Make a post"))),
        for (final post in posts) post.image
        //TODO replace with a more f ormatted post when/if we add extra data
      ],
    );
  }
}
