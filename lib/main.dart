import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      debugShowCheckedModeBanner: false,
      title: "قاعدة مركز صهيب",
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],     
      theme: ThemeData(        
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 107, 81, 5),
          titleTextStyle: TextStyle(fontFamily: 'arefruqaa', fontSize: 30),                    
        ),

        textTheme: TextTheme(
          titleMedium: TextStyle(fontSize: 20),
          bodyMedium: TextStyle(fontSize: 15, fontWeight: .bold),
          bodySmall: TextStyle(fontSize: 15),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            iconColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),

        datePickerTheme: const DatePickerThemeData(
          backgroundColor: Color(0xFFFFF8E1),
          headerBackgroundColor: Colors.amber,
          headerForegroundColor: Colors.black87,
        ),
      ),
      home: HomePage(studentDao: studentDao, classDao: classDao),
    );
  }
}
