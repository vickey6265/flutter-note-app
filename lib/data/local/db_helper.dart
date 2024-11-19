import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  ///singleton
  DBHelper._();

  static DBHelper getInstance() {
    return DBHelper._();
  }

  ///table note
  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TAG = "tag";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";
  static final String COLUMN_NOTE_TIME = "time";
  static final String COLUMN_NOTE_COLOR = "color";
  static final String COLUMN_NOTE_COMPLETED = "completed";

  //nullable global variable
  Database? myDB;

  ///db open (path -> is exists then open else create)
  Future<Database> getDB() async {
    //myDB = myDB ?? await openDB();
    myDB ??= await openDB();
    return myDB!;
    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        ///create all your tables here
        db.rawQuery(
            "create table $TABLE_NOTE($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TAG tag, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text, $COLUMN_NOTE_TIME text, $COLUMN_NOTE_COLOR text, $COLUMN_NOTE_COMPLETED text DEFAULT 'false')");
      },
      version: 3,
    );
  }

  ///all queries
  ///insertion
  Future<bool> addNote(
      {required String mTag,
      required String mTitle,
      required String mDesc,
      required String mTime,
      required String mColor,
      required String mCompleted}) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TAG: mTag,
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
      COLUMN_NOTE_TIME: mTime,
      COLUMN_NOTE_COLOR: mColor,
      COLUMN_NOTE_COMPLETED: mCompleted
    });

    return rowsEffected > 0;
  }

  ///reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

  ///update notes data
  Future<bool> updateNote(
      {required String mTag,
      required String mTitle,
      required String mDesc,
      required String mTime,
      required String mColor,
      required int mSNo,
      required String mCompleted}) async {
    var db = await getDB();
    int rowsEffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_TAG: mTag,
          COLUMN_NOTE_TITLE: mTitle,
          COLUMN_NOTE_DESC: mDesc,
          COLUMN_NOTE_TIME: mTime,
          COLUMN_NOTE_COLOR: mColor,
          COLUMN_NOTE_COMPLETED: mCompleted,
        },
        where: "$COLUMN_NOTE_SNO = $mSNo");
    return rowsEffected > 0;
  }

  Future<bool> markAsCompleteNote(
      {required int mSNo, required String mCompleted}) async {
    var db = await getDB();
    int rowsEffected = await db.update(
        TABLE_NOTE,
        {
          COLUMN_NOTE_COMPLETED: mCompleted,
        },
        where: "$COLUMN_NOTE_SNO = $mSNo");
    return rowsEffected > 0;
  }

  ///delete note
  Future<bool> deleteNote({required int mSNo}) async {
    var db = await getDB();
    int rowsEffected = await db.delete(TABLE_NOTE,
        where: "$COLUMN_NOTE_SNO = ?", whereArgs: ['$mSNo']);
    return rowsEffected > 0;
  }
}
