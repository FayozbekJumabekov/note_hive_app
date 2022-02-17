import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/db_service.dart';

class AddingNotesPage extends StatefulWidget {
  const AddingNotesPage({Key? key}) : super(key: key);
  static const String id = "note_add";

  @override
  _AddingNotesPageState createState() => _AddingNotesPageState();
}

class _AddingNotesPageState extends State<AddingNotesPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();


  /// Create new Note
  createNotes() {
    if(contentController.text.isNotEmpty){
      String title = titleController.text.toString().trim();
      String content = contentController.text.toString().trim();
      Note note = Note(
        id: content.hashCode,
        createTime: DateTime.now(),
        editTime: DateTime.now(),
        title: title,
        content: content,
      );
      List<Note> noteList = DBService.loadNotes();
      setState(() {
        noteList.add(note);
      });
      storeNote(noteList);
      Navigator.pop(context,true);
    }
    else {
      Navigator.pop(context,true);
    }
  }

  /// Store Created Note
  storeNote(List<Note> noteList) async {
    await DBService.storeNotes(noteList).then((value) => {
      noteList.forEach((element) {print(element.content);})
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        createNotes();
        return false;
      },
      child: Scaffold(
        /// Appbar
        appBar: AppBar(
          /// Back Button
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.arrow_left,
            ),
            onPressed: () {
              createNotes();
              contentController.clear();
              titleController.clear();
            },
          ),
          actions: [

            /// Save Button
            TextButton(
                onPressed: () {
                  createNotes();
                  contentController.clear();
                  titleController.clear();
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Theme.of(context).appBarTheme.iconTheme!.color,fontSize: 18),
                ))
          ],
        ),
        /// Body
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                /// Add title
                TextField(
                  controller: titleController,
                  cursorColor: Colors.amber,
                  cursorHeight: 30,
                  maxLines: null,

                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.subtitle2!.color),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: " Title",
                    hintStyle: TextStyle(
                        fontSize: 25,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                /// Add Content
                TextField(
                  controller: contentController,
                  cursorColor: Colors.amber,
                  cursorHeight: 22,
                  maxLines: null,
                  style: TextStyle(fontSize: 16,color: Theme.of(context).textTheme.subtitle2!.color),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: "  Start typing...",
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
