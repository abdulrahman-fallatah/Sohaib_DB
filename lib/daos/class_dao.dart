import 'package:sohaib_db/daos/daos.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sohaib_db/dart/objects.dart';

class ClassDao {
  final Database _db;

  ClassDao(this._db);

  void addClass(String className) {
    _db.execute('BEGIN');
    final stmt = _db.prepare('INSERT INTO classes (Class_name) VALUES (?)');
    try {
      final exist = _db.select('SELECT class_name FROM Classes WHERE class_name = ?', [className]);
      if(exist.isNotEmpty) throw Exception("الفصل ($className) موجود بالفعل");
      stmt.execute([className]);
      _db.execute('COMMIT');      
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.close();
    }
  }

  List<ClassRoom> getAllClasses() {
    final ResultSet classRows = _db.select('SELECT * FROM Classes');
    return classRows.map((e) => ClassRoom.fromMap(e)).toList();
  }

  void deleteClass(ClassRoom classRoom, [List<Student>? studentList]) {
    _db.execute('BEGIN');
    final stmt1 = _db.prepare('''DELETE FROM S_C WHERE S_C.class_id = ?''');
    final stmt2 = _db.prepare('''DELETE FROM Classes WHERE Classes.class_id = ?''');

    try {
      if (studentList != null) {
        for (var student in studentList) {
          _db.execute('DELETE FROM Attendance WHERE Attendance.student_id = ?', [student.studentID]);
          _db.execute('DELETE FROM S_C WHERE S_C.student_id = ?', [student.studentID]);
          _db.execute('DELETE FROM Students WHERE Students.student_id = ?', [student.studentID]);
        }
      }
      stmt1.execute([classRoom.classID]);
      stmt2.execute([classRoom.classID]);
      _db.execute('''COMMIT''');
    } catch (e) {
      _db.execute('''ROLLBACK''');
      rethrow;
    } finally {
      stmt1.close();
      stmt2.close();
    }
  }
}
