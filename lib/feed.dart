import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_sharing/send.dart';
import './post.dart';
import './network.dart';

class FeedTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<Post> posts = [];
  Future<NetworkLog> logFuture;

  void reload() {
    setState(() {});
  }

  void initState() {
    super.initState();
    logFuture = NetworkLog.getLog(reload);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: logFuture,
        builder: (BuildContext context, AsyncSnapshot<NetworkLog> snapshot) {
          if (snapshot.hasData)
            return loadFromLog(snapshot.data);
          else if (snapshot.hasError)
            return Text("Something went wrong");
          else
            return Center(child: CircularProgressIndicator());
        });
  }

  Widget loadFromLog(NetworkLog log) {
    print(log.feed.length);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Hero(
            tag: "post",
            child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SendTab(log)));
                  reload();
                },
                child: Text("Make a post"))),
        Text(log.feed.length.toString()),
        for (final post in log.feed) post,
        //TODO replace with a more formatted post when/if we add extra data
      ],
    );
  }
}
