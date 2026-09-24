import 'package:flutter/material.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/validators.dart';

class AttendancePage2 extends StatefulWidget {
  final StudentDao studentDao;
  final ClassRoom classRoom;
  final List<Student> studentList;
  final String selectedDate;

  const AttendancePage2({
    super.key,
    required this.studentDao,
    required this.classRoom,
    required this.studentList,
    required this.selectedDate,
  });

  @override
  State<AttendancePage2> createState() => _AttendancePage2State();
}

class _AttendancePage2State extends State<AttendancePage2> {
  late List<Student> studentList = widget.studentList;
  Map<Student, bool?> attendance = {};
  late bool isDone;

  @override
  void initState() {
    super.initState();

    isDone = widget.studentDao.isAttendanceTaken(
      widget.classRoom.className!,
      widget.selectedDate,
    );

    final Map<int, bool> savedAttendance = widget.studentDao
        .getTodayAttendanceByClass(
          widget.classRoom.className!,
          widget.selectedDate,
        );

    studentList = widget.studentDao.getStudentsByClass(
      widget.classRoom.className!,
    );
    attendance.clear();
    for (var student in studentList) {
      attendance[student] = savedAttendance[student.studentID];
    }
  }

  @override
  Widget build(BuildContext context) {
    StudentDao studentDao = widget.studentDao;
    ClassRoom classRoom = widget.classRoom;
    String selectedDate = widget.selectedDate;

    return Scaffold(
      appBar: AppBar(title: Text("${classRoom.className}  - ${selectedDate}")),

      floatingActionButton: studentList.length == 0
          ? null
          : FloatingActionButton.extended(
              icon: Icon(Icons.save_outlined),
              label: Text("تسجيل"),
              onPressed: () {
                bool unmarkedStudent =
                    attendance.length < studentList.length ||
                    attendance.values.contains(null);
                if (unmarkedStudent) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return Directionality(
                        textDirection: .rtl,
                        child: AlertDialog(
                          title: Text("يوجد طلاب غير محضّرين!"),
                          content: Text("الرجاء تحضير جميع الطلاب قبل التسجيل"),
                          actions: [
                            Center(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text("حسنا"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  return;
                }

                final Map<Student, bool> validAttendance = attendance.map(
                  ((key, value) => MapEntry(key, value!)),
                );

                try {
                  if (isDone) {
                    studentDao.updateAttendance(validAttendance, selectedDate);
                  } else {
                    studentDao.recordAttendance(validAttendance, selectedDate);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تم تحضير الطلاب بنجاح")),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  _errorOccurred(context, e, "تحضير الطلاب");
                }
              },
            ),

      body: studentList.length == 0
          ? Center(child: Text("لا يوجد طلاب في هذا الفصل"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      FilledButton(
                        child: Text("تحضير الكل"),
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < studentList.length; i++) {
                              attendance[studentList[i]] = true;
                            }
                          });
                        },
                      ),
                      FilledButton(
                        child: Text("تغييب الكل"),
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < studentList.length; i++) {
                              attendance[studentList[i]] = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: studentList.length,
                    itemBuilder: (context, i) {
                      final student = studentList[i];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              Validators().convertToEasternArabicNumbers(
                                "${i + 1}",
                              ),
                            ),
                          ),
                          title: Text(
                            student.fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          trailing: IconButton(
                            icon: _buildAttendanceIcon(attendance[student]),
                            onPressed: () {
                              setState(() {
                                _toggleAttendance(student);
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _toggleAttendance(student);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleAttendance(Student student) {
    final currentState = attendance[student];
    if (currentState == true) {
      attendance[student] = false;
    } else if (currentState == false) {
      attendance[student] = null;
    } else {
      attendance[student] = true;
    }
  }

  Widget _buildAttendanceIcon(bool? status) {
    switch (status) {
      case true:
        return Icon(Icons.check_box, color: Colors.green);
      case false:
        return Icon(Icons.disabled_by_default, color: Colors.red);
      default:
        return Icon(Icons.indeterminate_check_box, color: Colors.grey);
    }
  }

  void _errorOccurred(BuildContext context, Object e, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("حدث خطأ أثناء $text", textDirection: .rtl),
          content: Text("تفاصيل الخطأ:\n$e", textDirection: .rtl),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("حسنا"),
              ),
            ),
          ],
        );
      },
    );
  }
}
