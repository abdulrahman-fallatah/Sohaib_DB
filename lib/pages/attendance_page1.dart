import 'package:flutter/material.dart';
import 'package:hijri_date/hijri.dart';
import 'package:hijri_picker/hijri_picker.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';
import 'package:sohaib_db/pages/attendance_page2.dart';

class AttendancePage1 extends StatefulWidget {
  final StudentDao studentDao;
  final List<ClassRoom> classroomList;
  final List<Student> studentList;

  const AttendancePage1({
    super.key,
    required this.classroomList,
    required this.studentList,
    required this.studentDao});

  @override
  State<AttendancePage1> createState() => _AttendancePage1State();
}

class _AttendancePage1State extends State<AttendancePage1> {
  DateTime _currentDate = DateTime.now();
  late String dateString;    

  @override
  void initState() {
    super.initState();
    _updateDateString();
  }

  void _updateDateString() {
    var hijri = HijriDate.fromDate(_currentDate);
    dateString = hijri.toFormat('DDDD dd/MMMM/yyyy');
  }

  @override
  Widget build(BuildContext context) {
    final StudentDao studentDao = widget.studentDao;
    List<ClassRoom> classroomList = widget.classroomList;
    List<Student> studentList = widget.studentList;

    return Scaffold(
      appBar: AppBar(title: Text("تحضير الطلاب")),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [                  
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentDate = _currentDate.add(Duration(days: 1));
                        _updateDateString();
                      });
                    },
                  ),                  
                  TextButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      dateString,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onPressed: () async {
                      var picked = await showHijriDatePicker(
                        context: context,
                        initialDate: HijriDateTime.fromGregorian(_currentDate),
                        firstDate: HijriDateTime.fromGregorian(DateTime.now().subtract(Duration(days: 365))),
                        lastDate: HijriDateTime.fromGregorian(
                          DateTime.now().add(Duration(days: 365)),
                        ),
                        hijriLanguage: 'ar',
                      );
                      if (picked != null) {
                        setState(() {
                          _currentDate = picked.toGregorian();
                          _updateDateString();
                        });
                      }
                    },
                  ),                  
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentDate = _currentDate.subtract(Duration(days: 1));
                        _updateDateString();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: classroomList.length,
              itemBuilder: ((context, i) {
                final className = classroomList[i].className;
                final bool isDone = studentDao.isAttendanceTaken(
                  className!,
                  dateString,
                );
                return Card(
                  color: isDone ? Colors.green : Colors.blueGrey,
                  child: ListTile(
                    title: Text(
                      "الفصل: $className",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: .center,
                    ),
                    subtitle: isDone
                        ? Text("تم التحضير", textAlign: .center)
                        : Text("لم يتم التحضير", textAlign: .center),
                    leading: CircleAvatar(
                      child: Text(
                        Validators().convertToEasternArabicNumbers("${i + 1}"),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    trailing: Column(
                      mainAxisSize: .min,
                      children: [
                        Text(
                          "عدد طلاب الفصل",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          Validators().convertToEasternArabicNumbers(
                            "${studentDao.getStudentCountByClass(className)}",
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (isDone) {
                        bool? confirm = await showDialog<bool>(
                          barrierDismissible: false,
                          context: context,
                          builder: (dialogContext) {
                            return Directionality(
                              textDirection: .rtl,
                              child: AlertDialog(
                                title: Text("تم التحضير"),
                                content: Text(
                                  "لقد تم تحضير هذا اليوم بالفعل، هل تريد إعادة التحضير؟",
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: .spaceEvenly,
                                    children: [
                                      FilledButton(
                                        child: Text("نعم"),
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),
                                      ),
                                      FilledButton(
                                        child: Text("لا"),
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (confirm == true && context.mounted) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AttendancePage2(
                                studentDao: studentDao,
                                classRoom: classroomList[i],
                                studentList: studentList,
                                selectedDate: dateString,
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      } else {
                        if (context.mounted) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AttendancePage2(
                                studentDao: studentDao,
                                classRoom: classroomList[i],
                                studentList: studentList,
                                selectedDate: dateString,
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      }
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
