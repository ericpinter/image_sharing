import 'dart:async';
import 'dart:collection';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../network/friends_model.dart';

class FriendDatabase {
  static Database friendsDb;

  static init() async {
    if (friendsDb == null) {
      friendsDb = await getDatabasesPath().then((dbPath) => openDatabase(
            join(dbPath, 'friends_database.db'),
            onCreate: (db, version) {
              //sql command inside db.execute
              return db.execute(
                  "CREATE TABLE friends(ip TEXT PRIMARY KEY, name TEXT, online INTEGER)");
            },
            version: 1,
          ));
    }
    return friendsDb;
  }

  static Future<void> insertFriend(Friend friend) async {
    await friendsDb.insert(
      'friends',
      friend.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Friend>> friends() async {
    final List<Map<String, dynamic>> maps = await friendsDb.query('friends');

    //ip not inside {} of friend model constructor
    return List.generate(maps.length, (i) {
      return Friend(
        maps[i]['ip'],
        name: maps[i]['name'],
        online: maps[i]['online'] == 1 ? true : false,
      );
    });
  }

  static Future<LinkedHashMap<String, Friend>> toFriendMap() async {
    var friendList = await friends();
    var ipMap = LinkedHashMap<String, Friend>();
    for (Friend f in friendList) {
      ipMap.putIfAbsent(f.ip, () => f);
    }

    return ipMap;
  }

  static Future<void> deleteFriend(int ip) async {
    await friendsDb.delete(
      'friends',
      where: "ip = ?",
      whereArgs: [ip],
    );
  }

  static Future<Friend> getFriend(int ip) async {
    var map = await friendsDb.query(
      'friends',
      where: "ip = ?",
      whereArgs: [ip],
    );

    return Friend(
      map[0]['ip'],
      name: map[0]['name'],
      online: map[0]['online'] == 1 ? true : false,
    );

  }


  static Future<void> updateFriend(Friend friend) async {
    await friendsDb.update(
      'friends',
      friend.toJson(),
      where: "ip = ?",
      whereArgs: [friend.ip],
    );
  }
}
