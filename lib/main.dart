import 'package:flutter/material.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HijriDate.setLocal('ar');

  await DatabaseManager().initDatabase();    

  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final studentDao = StudentDao(DatabaseManager.db);
  final classDao = ClassDao(DatabaseManager.db);


  MyApp({super.key});  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(        
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 107, 81, 5),
          titleTextStyle: TextStyle(fontFamily: 'arefruqaa', fontSize: 30),          
        ),
        textTheme: TextTheme(
          titleMedium: TextStyle(fontSize: 20),
          bodySmall: TextStyle(fontSize: 15),
        ),
        
      ),
      home: HomePage(studentDao: studentDao, classDao: classDao,),      
    );
  }
}
