import 'package:flutter/material.dart';
import './friends_tab.dart';
import './feed.dart';
import 'database/friends_database.dart';
import 'network/friends_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FriendDatabase.init();
  await Friends.init();
  //TODO await Feed.init()

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var tabs = [FriendsTab(), FeedTab()];
    var tabStrings = ["Friends", "Feed"];

    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
              title: Text(widget.title),
              bottom: TabBar(
                isScrollable: false,
                tabs: [for (final label in tabStrings) Tab(text: label)],
              )),
          body: TabBarView(children: [
            for (final tab in tabs) Center(child: tab),
          ]),
        ));
  }
}
