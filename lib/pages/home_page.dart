import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../main.dart';
import '../models/note_model.dart';
import '../services/db_service.dart';
import 'note_add_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = "home_page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  List<Note> listNote = [];
  String search = "";
  late List<bool> checkEdits;
  bool isSelected = false;
  bool editText = false;
  bool isDarkMode = false;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    loadNoteList();
  }

  /// Load Notes

  void loadNoteList() {
    setState(() {
      listNote = DBService.loadNotes();
      checkEdits = List.generate(listNote.length, (index) => false);
    });
  }

  /// Store Notes
  void storeNote() async {
    await DBService.storeNotes(listNote).then((value) =>
    {
      listNote.forEach((element) {
        print(element.content);
      })
    });
    checkEdits = List.generate(listNote.length, (index) => false);
  }

  /// Remove Notes
  void removeNoteList() async {
    if (isSelected) {
      List<Note> list = [];
      for (var i = 0; i < checkEdits.length; i++) {
        if (!checkEdits[i]) list.add(listNote[i]);
      }
      listNote = list;
      isSelected = false;
      storeNote();
      setState(() {});
    }
  }


  /// Receive Data from AddingNotePage
  void _openAddNotesPage() async {
    var result = await Navigator.pushNamed(context, AddingNotesPage.id);
    if (result != null && result == true) {
      setState(() {
        loadNoteList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,

      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          title: Text("Notes", style: TextStyle(fontSize: 22),),
          actions: [

            /// Delete Button
            (isSelected)
                ? IconButton(
                onPressed: () {
                  setState(() {
                    removeNoteList();
                  });
                },
                icon: Icon(Icons.delete))
                : SizedBox.shrink(),

            /// Dark Mode Button
            IconButton(
                onPressed: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                    isDarkMode
                        ? MyApp.of(context)?.changeTheme(ThemeMode.dark)
                        : MyApp.of(context)?.changeTheme(ThemeMode.light);
                  });
                },
                icon:
                (isDarkMode) ? Icon(Icons.light_mode) : Icon(Icons.dark_mode))
          ],

          /// Search TextField
          bottom: PreferredSize(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .appBarTheme
                        .foregroundColor,
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  cursorColor: Colors.amber,
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      setState(() {
                        search = text.trim();
                      });
                    }
                    else {
                      setState(() {
                        search = "";
                      });
                    }
                  },
                  decoration: InputDecoration(
                      hintText: "Search notes",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.amber,
                      ),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                ),
              ),
              preferredSize: Size(200, 40)),
        ),

        /// Body
        body: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Theme
                .of(context)
                .scaffoldBackgroundColor,
            child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemCount: (search.isEmpty) ? listNote.length : listNote
                    .where((element) =>
                    element.title.toLowerCase().contains(search.toLowerCase()))
                    .toList()
                    .length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (ctx, index) {
                  return (search.isEmpty) ? noteItems(
                      index, context, listNote[index]) : noteItems(
                      index, context, listNote.where((element) =>
                      element.title.toLowerCase().contains(
                          search.toLowerCase())).toList()[index]);
                }),
          ),
        ),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
            _openAddNotesPage();
          },
          child: Icon(
            Icons.add,
            size: 40,
          ),
        ),
      ),
    );
  }

  /// Notes Items
  GestureDetector noteItems(int index, BuildContext context, Note note) {
    return GestureDetector(
      onLongPress: () {
        isSelected = true;
        setState(() {
          checkEdits[index] = true;
        });
      },
      onTap: () {
        if (isSelected)
          setState(() {
            checkEdits[index] = !checkEdits[index];
          });
        for (var checked in checkEdits) {
          if (checked) {
            isSelected = true;
            break;
          } else {
            setState(() {
              isSelected = false;
            });
          }
        }
      },
      child: GridTile(
        header: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 50,
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .appBarTheme
                  .backgroundColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15)),
              border: Border.all(color: Colors.amber.shade100)),
          child: Text(
            note.title,
            style: TextStyle(fontSize: 18),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        child: Container(
          padding: EdgeInsets.only(top: 55, left: 10),
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .appBarTheme
                  .foregroundColor,
              gradient: (checkEdits[index])
                  ? LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.2),
                    Colors.blue.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ])
                  : null,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber.shade100)),
          child: Text(
            note.content,
            style: TextStyle(fontSize: 14, color: Colors.black),
            maxLines: null,
            textAlign: TextAlign.start,
          ),
        ),
        footer: Container(
          padding: EdgeInsets.only(left: 10),
          height: 40,
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .appBarTheme
                  .backgroundColor,

              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15)),
              border: Border.all(color: Colors.amber.shade100)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.createTime.toString().substring(0, 16),
                style: TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              editButton(context, index)
            ],
          ),
        ),
      ),
    );
  }

  /// Awesome Dialog For Edit
  IconButton editButton(BuildContext context, int index) {
    return IconButton(
        onPressed: () {
          setState(() {
            editText = true;
          });
          late AwesomeDialog dialog;
          dialog = AwesomeDialog(
            dialogBackgroundColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            context: context,
            animType: AnimType.SCALE,
            dialogType: DialogType.INFO_REVERSED,
            keyboardAware: true,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Edit Note',
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .textTheme
                            .bodyText2!
                            .color),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Material(
                    elevation: 0,
                    color: Colors.blueGrey.withAlpha(40),
                    child: TextFormField(
                      controller: titleController
                        ..text = (editText) ? listNote[index].title : "",
                      autofocus: true,
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2!
                              .color),
                      minLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Title',
                        labelStyle: TextStyle(
                            color: Theme
                                .of(context)
                                .listTileTheme
                                .textColor),
                        prefixIcon: Icon(
                          Icons.text_fields,
                          color: Theme
                              .of(context)
                              .appBarTheme
                              .iconTheme!
                              .color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Material(
                    elevation: 0,
                    color: Colors.blueGrey.withAlpha(40),
                    child: TextFormField(
                      controller: contentController
                        ..text = (editText) ? listNote[index].content : "",
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2!
                              .color),
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      maxLengthEnforced: true,
                      minLines: 2,
                      maxLines: 8,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Content',
                        labelStyle: TextStyle(
                            color: Theme
                                .of(context)
                                .listTileTheme
                                .textColor),
                        prefixIcon: Icon(
                          Icons.text_fields,
                          color: Theme
                              .of(context)
                              .appBarTheme
                              .iconTheme!
                              .color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedButton(
                            color: Colors.red,
                            isFixedHeight: false,
                            text: 'Close',
                            pressEvent: () {
                              dialog.dismiss();
                              setState(() {
                                contentController.clear();
                                titleController.clear();
                              });
                            }),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: AnimatedButton(
                            color: Colors.green,
                            isFixedHeight: false,
                            text: 'Save',
                            pressEvent: () {
                              setState(() {
                                listNote[index].content =
                                    contentController.text.toString();
                                listNote[index].title =
                                    titleController.text.toString();
                                storeNote();
                                dialog.dismiss();
                                contentController.clear();
                                titleController.clear();
                                editText = false;
                              });
                            }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
            ..show();
        },
        icon: Icon(Icons.edit));
  }

  /// OnWillPop for Unselect all Items
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      isSelected = false;
      checkEdits = List.generate(listNote.length, (index) => false);
      setState(() {});
      return Future.value(false);
    }
    return Future.value(true);
  }
}
