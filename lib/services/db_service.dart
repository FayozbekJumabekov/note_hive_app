import 'package:hive/hive.dart';
import 'package:note_hive_app/models/note_model.dart';
import 'dart:convert';

class DBService {
  static const String dbName = "db_notes";
  static Box box = Hive.box(dbName);

  static Future<void> storeNotes(List<Note> noteList) async {
    List<String> stringList =
        noteList.map((note) => jsonEncode(note.toJson())).toList();
    await box.put('notes', stringList);
  }

  static List<Note> loadNotes()  {
    List<String> stringList = box.get('notes') ?? <String>[];
    return stringList.map((stringNote) => Note.fromJson(jsonDecode(stringNote))).toList();
  }

  static Future<void> removeNotes() async {
    await box.delete("notes");
  }
}
