import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
export 'student_dao.dart';
export 'class_dao.dart';

class DatabaseManager {

  static late final Database db;  

  Future<void> initDatabase() async {

    final docDir = await getApplicationDocumentsDirectory();
    final dbLocation = p.join(docDir.path, "sohaib_database.db");
    db = sqlite3.open(dbLocation);    
    

    _createTables(db);

  }
  
  void _createTables(Database db){

    db.execute('''PRAGMA foreign_keys = ON;''');

    db.execute('''CREATE TABLE IF NOT EXISTS "Students" (
    "student_id"	INTEGER NOT NULL UNIQUE,
    "fullName"	TEXT NOT NULL,
    "presentDays"	INTEGER DEFAULT 0,
    "absentDays"	INTEGER DEFAULT 0,
    PRIMARY KEY("student_id" AUTOINCREMENT)
    );
    ''');

    db.execute('''CREATE TABLE IF NOT EXISTS "Classes" (
    "class_id"	INTEGER NOT NULL UNIQUE,
    "class_name"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("class_id" AUTOINCREMENT)
    );
    ''');

    db.execute('''CREATE TABLE IF NOT EXISTS "S_C" (
    "student_id"	INTEGER UNIQUE,
    "class_id"	INTEGER,
    PRIMARY KEY("student_id","class_id"),
    FOREIGN KEY("class_id") REFERENCES "Classes"("class_id"),
    FOREIGN KEY("student_id") REFERENCES "Students"("student_id")
    );
    ''');

    db.execute('''CREATE TABLE IF NOT EXISTS "Attendance" (
    "log_id"	INTEGER,
    "student_id"	INTEGER,
    "date"	TEXT,
    "status"	TEXT,
    PRIMARY KEY("log_id" AUTOINCREMENT)
    );
    ''');

  }
}
