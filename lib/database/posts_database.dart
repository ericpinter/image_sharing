import 'dart:async';
import 'dart:collection';
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
                  "CREATE TABLE posts(image TEXT PRIMARY KEY, sender TEXT FOREIGN KEY)");
            },
            version: 1,
          ));
    }
    return postsDb;
  }

  static Future<void> insertPost(Post post) async {
    await postsDb.insert(
      'posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Post>> friends() async {
    final List<Map<String, dynamic>> maps = await postsDb.query('posts');

    return List.generate(maps.length, (i) {
      return Post(maps[i]['image'], maps[i]['sender']);
    });
  }

  static Future<void> deleteFriend(int image) async {
    await postsDb.delete(
      'posts',
      where: "image = ?",
      whereArgs: [image],
    );
  }

  static Future<void> updateFriend(Post post) async {
    await postsDb.update(
      'posts',
      post.toMap(),
      where: "image = ?",
      whereArgs: [post.image],
    );
  }
}
