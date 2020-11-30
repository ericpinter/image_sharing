import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../network/friends_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> friendsDb = openDatabase(
    join(await getDatabasesPath(), 'friends_database.db'),
    onCreate: (db, version) {
      //sql command inside db.execute
      return db.execute(
          "CREATE TABLE friends(ip TEXT PRIMARY KEY, name TEXT, online INTEGER)");
    },
    version: 1,
  );

  Future<void> insertFriend(Friend friend) async {
    final Database db = await friendsDb;

    await db.insert(
      'friends',
      friend.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Friend>> friends() async {
    final Database db = await friendsDb;

    final List<Map<String, dynamic>> maps = await db.query('friends');

    //ip not inside {} of friend model constructor
    return List.generate(maps.length, (i) {
      return Friend(
        name: maps[i]['name'],
        online: maps[i]['online'],
        ip: maps[i]['ip'],
      );
    });
  }

  Future<void> deleteFriend(int ip) async {
    final db = await friendsDb;

    await db.delete(
      'friends',
      where: "ip = ?",
      whereArgs: [ip],
    );
  }

  Future<void> updateFriend(Friend friend) async {
    final db = await friendsDb;

    await db.update(
      'friends',
      friend.toJson(),
      where: "ip = ?",
      whereArgs: [friend.ip],
    );
  }
}
