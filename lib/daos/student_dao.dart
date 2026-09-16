import 'package:sqlite3/sqlite3.dart';
import 'package:sohaib_db/dart/objects.dart';

class StudentDao {
  final Database _db;

  StudentDao(this._db);

  void addStudentWithClass(String name, String className) {
    _db.execute('BEGIN');
    final stmt = _db.prepare('INSERT INTO Students (FullName) VALUES (?)');
    final assignStmt = _db.prepare(
      'INSERT INTO S_C (student_id, class_id) VALUES (?, ?)',
    );

    try {
      final ResultSet exist = _db.select(
        '''SELECT Students.fullName FROM Students
      JOIN S_C ON Students.student_id = S_C.student_id
      JOIN Classes ON S_C.class_id = Classes.class_id
      WHERE Classes.class_name = ?''',
        [className],
      );

      if (exist.any((e) => e.containsValue(name))) {
        throw Exception(
          "هذا الطالب موجود بالفعل في هذا الفصل، الرجاء تغيير اسم الطالب أو الفصل",
        );
      }

      stmt.execute([name]);
      final studentId = _db.lastInsertRowId;

      final classResult = _db.select(
        'SELECT class_id FROM classes WHERE Class_name = ?',
        [className],
      );

      if (classResult.isEmpty) {
        throw FormatException(
          'الفصل ($className) غير موجود! يرجى إضافة الفصل أولاً.',
        );
      }

      final classID = classResult.first['class_id'];

      assignStmt.execute([studentId, classID]);
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.close();
      assignStmt.close();
    }
  }

  List<(String, String)> addMultipleStudents(
    List<(String, String)> studentsToAdd,
  ) {
    _db.execute('BEGIN');
    List<(String, String)> failedList = [];
    List<PreparedStatement> stmtList = List.generate(
      studentsToAdd.length,
      (i) => _db.prepare('INSERT INTO Students (FullName) VALUES (?)'),
    );
    List<PreparedStatement> assignStmtList = List.generate(
      studentsToAdd.length,
      (i) =>
          _db.prepare('INSERT INTO S_C (student_id, class_id) VALUES (?, ?)'),
    );

    for (int i = 0; i < studentsToAdd.length; i++) {
      _db.execute('SAVEPOINT sp');
      String name = studentsToAdd[i].$1;
      String className = studentsToAdd[i].$2;
      try {
        final ResultSet exist = _db.select(
          '''SELECT Students.fullName FROM Students
      JOIN S_C ON Students.student_id = S_C.student_id
      JOIN Classes ON S_C.class_id = Classes.class_id
      WHERE Classes.class_name = ?''',
          [className],
        );

        if (exist.any((e) => e.containsValue(name))) {
          throw "هذا الطالب موجود بالفعل في هذا الفصل، الرجاء تغيير اسم الطالب أو الفصل";
        }

        final classResult = _db.select(
          '''
      SELECT class_id FROM Classes WHERE class_name = ?
      ''',
          [className],
        );

        if (classResult.isEmpty) {
          throw "الفصل ($className) غير موجود! يرجى إضافة الفصل أولاً.";
        }
        final classID = classResult.first['class_id'];

        stmtList[i].execute([name]);
        final studentID = _db.lastInsertRowId;
        assignStmtList[i].execute([studentID, classID]);
        _db.execute('RELEASE sp');
      } catch (e) {
        failedList.add((name, e.toString()));
        _db.execute('ROLLBACK TO sp');
        _db.execute('RELEASE sp');
      } finally {
        stmtList[i].close();
        assignStmtList[i].close();
      }
    }
    _db.execute('COMMIT');
    return failedList;
  }

  List<Student> getAllStudents() {
    final ResultSet rows = _db.select('''
    SELECT * FROM Students
    JOIN S_C on Students.student_id = S_C.student_id
    JOIN Classes on S_C.class_id = Classes.class_id
    ORDER BY Classes.class_name
    ''');
    return rows.map((e) => Student.fromMap(e)).toList();
  }

  List<Student> getStudentsByClass(String className) {
    final classIds = _db.select(
      "SELECT class_id FROM Classes WHERE class_name = ?",
      [className],
    );
    final int classId = int.parse(classIds.first.values.first.toString());

    final ResultSet studentRows = _db.select(
      '''
      SELECT * FROM Students
      JOIN S_C on Students.student_id = S_C.student_id
      JOIN Classes on S_C.class_id = Classes.class_id
      WHERE S_C.class_id = ?
      GROUP BY Students.student_id
    ''',
      [classId],
    );
    return studentRows.map((e) => Student.fromMap(e)).toList();
  }

  List<Map<String, dynamic>> getStudentAttendanceDetails(String studentId) {
    final ResultSet rows = _db.select(
      '''
      SELECT * FROM Students
      JOIN Attendance ON Students.student_id = Attendance.student_id
      JOIN S_C ON Students.student_id = S_C.student_id
      JOIN Classes ON S_C.class_id = Classes.class_id
      WHERE Students.student_id = ?
    ''',
      [studentId],
    );

    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  int getStudentCountByClass(String? className) {
    final result = _db.select(
      '''
    SELECT COUNT(*) AS total 
    FROM S_C
    JOIN Classes ON S_C.class_id = Classes.class_id
    WHERE Classes.class_name = ?
    ''',
      [className],
    );

    return result.first['total'] as int;
  }

  void recordAttendance(Map<Student, bool> attendanceData, String today) {
    _db.execute('BEGIN');
    final stmt = _db.prepare(
      'INSERT INTO Attendance (student_id, date, status) VALUES (?,?,?)',
    );
    final stmtPresent = _db.prepare(
      'UPDATE Students SET presentDays = presentDays + 1 WHERE student_id = ?',
    );
    final stmtabsent = _db.prepare(
      'UPDATE Students SET absentDays = absentDays + 1 WHERE student_id = ?',
    );
    try {
      for (var entry in attendanceData.entries) {
        final student = entry.key;
        final isPresent = entry.value;

        stmt.execute([student.studentID, today, isPresent ? 'حاضر' : 'غائب']);

        if (isPresent) {
          stmtPresent.execute([student.studentID]);
        } else {
          stmtabsent.execute([student.studentID]);
        }
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.close();
      stmtPresent.close();
      stmtabsent.close();
    }
  }

  void updateAttendance(Map<Student, bool> attendanceData, String today) {
    _db.execute('BEGIN');

    final stmt = _db.prepare(
      'UPDATE Attendance SET status = ? WHERE student_id = ? AND date = ?',
    );
    final stmtOldStatus = _db.prepare('''
      SELECT status as status FROM Attendance WHERE student_id = ? AND date = ?
      ''');
    final stmtPresent = _db.prepare(
      'UPDATE Students SET absentDays = absentDays - 1, presentDays = presentDays + 1 WHERE student_id = ?',
    );
    final stmtabsent = _db.prepare(
      'UPDATE Students SET presentDays = presentDays - 1, absentDays = absentDays + 1 WHERE student_id = ?',
    );
    try {
      for (var entry in attendanceData.entries) {
        final Student student = entry.key;
        final bool status = entry.value;
        final ResultSet oldStatusResult = stmtOldStatus.select([
          student.studentID,
          today,
        ]);
        if (oldStatusResult.isEmpty) {
          _db.execute(
            'INSERT INTO Attendance (student_id, date, status) VALUES (?,?,?)',
            [student.studentID, today, status == true ? 'حاضر' : 'غائب'],
          );
          status == true
              ? _db.execute(
                  'UPDATE Students SET presentDays = presentDays + 1 WHERE student_id = ?',
                  [student.studentID],
                )
              : _db.execute(
                  'UPDATE Students SET absentDays = absentDays + 1 WHERE student_id = ?',
                  [student.studentID],
                );
          continue;
        }
        final oldStatus = oldStatusResult.first['status'] == 'حاضر'
            ? true
            : false;

        if (oldStatus == status) continue;

        stmt.execute([status ? 'حاضر' : 'غائب', student.studentID, today]);

        if (status) {
          stmtPresent.execute([student.studentID]);
        } else {
          stmtabsent.execute([student.studentID]);
        }
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.close();
      stmtOldStatus.close();
      stmtPresent.close();
      stmtabsent.close();
    }
  }

  Map<int, bool> getTodayAttendanceByClass(String className, String today) {
    final ResultSet result = _db.select(
      '''
    SELECT Attendance.student_id, Attendance.status FROM Attendance
    JOIN S_C ON Attendance.student_id = S_C.student_id
    JOIN Classes ON S_C.class_id = Classes.class_id
    WHERE Classes.class_name = ? AND Attendance.date = ?
    ''',
      [className, today],
    );

    final Map<int, bool> map = {};
    for (var row in result) {
      map[row['student_id'] as int] = row['status'] == 'حاضر';
    }
    return map;
  }

  bool isAttendanceTaken(String className, String today) {
    final result = _db.select(
      '''
    SELECT COUNT(*) as total FROM Attendance
    JOIN S_C ON Attendance.student_id = S_C.student_id
    JOIN Classes ON S_C.class_id = Classes.class_id
    WHERE Classes.class_name = ? AND Attendance.date = ?
    ''',
      [className, today],
    );

    return result.first['total'] > 0;
  }

  void deleteStudent(List<Student> studentList) {
    _db.execute('BEGIN');

    try {
      for (var student in studentList) {
        _db.execute('DELETE FROM Attendance WHERE Attendance.student_id = ?', [
          student.studentID,
        ]);
        _db.execute('DELETE FROM S_C WHERE S_C.student_id = ?', [
          student.studentID,
        ]);
        _db.execute('DELETE FROM Students WHERE Students.student_id = ?', [
          student.studentID,
        ]);
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  void updateStudentName(String studentID, String? newName) {
    _db.execute('BEGIN');
    final stmt = _db.prepare(
      'UPDATE Students SET fullName = ? WHERE student_id = ?',
    );

    try {
      stmt.execute([newName, studentID]);
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.close();
    }
  }

  void updateStudentClass(String studentId, String newClassName) {
    _db.execute('BEGIN');
    final stmt = _db.prepare(
      'UPDATE S_C SET class_id = ? WHERE student_id = ?',
    );

    try {
      final classResult = _db.select(
        'SELECT class_id FROM classes WHERE Class_name = ?',
        [newClassName],
      );

      if (classResult.isEmpty) {
        throw FormatException(
          'الفصل ($newClassName) غير موجود! يرجى التأكد من اسم الفصل .',
        );
      }

      final newClassId = classResult.first['class_id'];

      stmt.execute([newClassId, studentId]);
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      stmt.close();
    }
  }

  void updateAttendanceForOne(
    String logId,
    String studentId,
    String newStatus,
    String oldStatus,
  ) {
    if (newStatus == oldStatus) return;

    _db.execute('BEGIN');
    try {
      _db.execute('UPDATE Attendance SET status = ? WHERE log_id = ?', [
        newStatus,
        logId,
      ]);

      if (newStatus == 'حاضر') {
        _db.execute(
          'UPDATE Students SET presentDays = presentDays + 1, absentDays = absentDays - 1 WHERE student_id = ?',
          [studentId],
        );
      } else {
        _db.execute(
          'UPDATE Students SET presentDays = presentDays - 1, absentDays = absentDays + 1 WHERE student_id = ?',
          [studentId],
        );
      }

      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }
}
