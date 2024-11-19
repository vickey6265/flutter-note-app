import 'package:first_flutter/data/local/db_helper.dart';
import 'package:flutter/cupertino.dart';

class DBProvider extends ChangeNotifier {
  DBHelper dbHelper;

  DBProvider({required this.dbHelper});

  List<Map<String, dynamic>> _mData = [];

  ///events
  void addNote(String tag, String title, String desc, String time,
      Color noteColor, String completed) async {
    bool check = await dbHelper.addNote(
      mTag: tag,
      mTitle: title,
      mDesc: desc,
      mTime: time,
      mColor: noteColor.value.toRadixString(16),
      mCompleted: completed,
    );
    if (check) {
      _mData = await dbHelper.getAllNotes();
      notifyListeners();
    }
  }

  ///update note
  void updateNote(String tag, String title, String desc, String time, int sno,
      Color noteColor, String completed) async {
    bool check = await dbHelper.updateNote(
      mTag: tag,
      mTitle: title,
      mDesc: desc,
      mSNo: sno,
      mTime: time,
      mColor: noteColor.value.toRadixString(16),
      mCompleted: completed,
    );
    if (check) {
      _mData = await dbHelper.getAllNotes();
      notifyListeners();
    }
  }

  ///delete note
  void deleteNote(int sno) async {
    bool check = await dbHelper.deleteNote(mSNo: sno);
    if (check) {
      _mData = await dbHelper.getAllNotes();
      notifyListeners();
    }
  }

  ///mark as completed note
  Future<void> markAsCompletedNote(int sno, String completed) async {
    bool check =
        await dbHelper.markAsCompleteNote(mSNo: sno, mCompleted: completed);
    if (check) {
      _mData = await dbHelper.getAllNotes();
      notifyListeners();
    }
  }

  ///get notes
  List<Map<String, dynamic>> getNotes() => _mData;

  void getInitialNotes() async {
    _mData = await dbHelper.getAllNotes();
    notifyListeners();
  }
}
