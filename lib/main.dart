import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_hive_app/pages/home_page.dart';
import 'package:note_hive_app/pages/note_add_page.dart';
import 'package:note_hive_app/services/db_service.dart';

void main() async{

  await Hive.initFlutter();
  await Hive.openBox(DBService.dbName);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {

  ThemeMode _themeMode  = ThemeMode.system ;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              foregroundColor: Colors.amber.shade50,
              titleTextStyle: TextStyle(color: Colors.amber,fontSize: 22,fontWeight: FontWeight.w600),
              iconTheme: IconThemeData(color: Colors.black)),
          textTheme: TextTheme(
            button: TextStyle(color: Colors.amber,fontSize: 18),
              bodyText2: TextStyle(color: Colors.black),
              subtitle2: TextStyle(color: Colors.black),
              caption: TextStyle(color: Colors.grey.shade800)

          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.amber,
          )
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        dividerColor: Colors.grey.shade500,
        textTheme: TextTheme(
            subtitle2: TextStyle(color: Colors.grey.shade200),
            bodyText2: TextStyle(color: Colors.grey)
        ),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.shade900,
            foregroundColor: Colors.blueGrey.shade800,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            iconTheme: IconThemeData(color: Colors.grey.shade200)),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber.withOpacity(0.6),
        )
      ),
      themeMode: _themeMode,
      home: HomePage(),
      routes: {
        HomePage.id: (context) => HomePage(),
        AddingNotesPage.id:(context)=>AddingNotesPage()
      },
    );
  }
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}
