import 'dart:async';
import 'package:flutter/widgets.dart' as Widgets;
import 'package:image_sharing/database/friends_database.dart';
import 'package:image_sharing/database/image_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_sharing/post.dart';

class PostDatabase {
  static Database postsDb;

  static init() async {
    if (postsDb == null) {
      postsDb = await getDatabasesPath().then((dbPath) => openDatabase(
            join(dbPath, 'posts_database.db'),
            onCreate: (db, version) {
              //convert image to BASE64 and store into sql database as a string
              return db.execute(
                  "CREATE TABLE posts(image BLOB PRIMARY KEY, sender TEXT REFERENCES friends (ip))");
            },
            version: 1,
          ));
    }
    return postsDb;
  }

  static Future<void> insertPost(Post post) async {
    await postsDb.insert(
      'posts',
      await post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Post>> posts() async {
    final List<Map<String, dynamic>> maps = await postsDb.query('posts');
    print("attempting");
    return [
      for (int i = 0; i < maps.length; i++)
        Post(await bytesToUI(maps[i]['image']),
            await FriendDatabase.getFriend(maps[i]['sender']))
    ];
  }
  /*
  static Future<void> deletePost(int image) async {
    await postsDb.delete(
      'posts',
      where: "image = ?",
      whereArgs: [image],
    );
  }

  static Future<void> updatePost(Post post) async {
    await postsDb.update(
      'posts',
      await post.toMap(),
      where: "image = ?",
      whereArgs: [post.image],
    );
  }*/
}
