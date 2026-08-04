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
}
