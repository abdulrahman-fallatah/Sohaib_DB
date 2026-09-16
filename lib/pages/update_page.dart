import 'package:flutter/material.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';

class UpdatePage extends StatefulWidget {
  final Student student;

  const UpdatePage({super.key, required this.student});

  @override
  State<UpdatePage> createState() => _UpdatePage();
}

class _UpdatePage extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final StudentDao studentDao = StudentDao(DatabaseManager.db);
  final ClassDao classDao = ClassDao(DatabaseManager.db);

  @override
  Widget build(BuildContext context) {
    final Student student = widget.student;
    final List<ClassRoom> classroomList = classDao.getAllClasses();
    String? name;
    String? className;
    late String? confirmClass;
    final List<Student> studentList = studentDao.getAllStudents();

    return Scaffold(
      appBar: AppBar(title: Text("تعديل معلومات طالب")),
      body: Directionality(
        textDirection: .rtl,
        child: ListView(
          children: [
            Card(
              color: Colors.amber,
              child: ListTile(
                title: Text(
                  "اسم الطالب: ${student.fullName}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  "الفصل: ${student.assignedClass}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: Row(
                  mainAxisSize: .min,
                  spacing: 10,
                  children: [
                    Column(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          "أيام الحضور",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          Validators().convertToEasternArabicNumbers(
                            student.presentDays.toString(),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          "أيام الغياب",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          Validators().convertToEasternArabicNumbers(
                            student.absentDays.toString(),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),

            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text("الاسم الجديد"),
                        hint: Text("اسم الطالب"),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return null;
                        }
                        if (!Validators().onlyLetters(val)) {
                          return "اسم الطالب يجب أن يحتوي على أحرف عربية فقط";
                        }
                        return null;
                      },
                      onSaved: (val) {
                        if (val!.isEmpty) {
                          name = null;
                        } else {
                          name = val.trim();
                        }
                      },
                    ),
                    SizedBox(height: 20),

                    DropdownMenuFormField(
                      dropdownMenuEntries: [
                        ...List.generate(classroomList.length, (i) {
                          return DropdownMenuEntry(
                            value: classroomList[i].className,
                            label: classroomList[i].className!,
                          );
                        }),
                        DropdownMenuEntry(value: null, label: "إلغاء"),
                      ],
                      onSaved: (val) {
                        className = val;
                      },
                    ),
                    SizedBox(height: 15),

                    FilledButton(
                      child: Text("تأكيد"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                        }

                        confirmClass = className ?? student.assignedClass;

                        try {
                          for (final s in studentList) {
                            if (s.fullName == name &&
                                s.assignedClass == confirmClass) {
                              throw "هذا الطالب موجود بالفعل، جرب تغيير الاسم أو الفصل";
                            }
                          }

                          if (name != null) {
                            studentDao.updateStudentName(
                              student.studentID.toString(),
                              name,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("تم تعديل اسم الطالب بنجاح"),
                              ),
                            );
                            setState(() {
                              student.fullName = name!;
                            });
                          }
                          if (className != null) {
                            studentDao.updateStudentClass(
                              student.studentID.toString(),
                              className!,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("تم تعديل فصل الطالب بنجاح"),
                              ),
                            );
                            setState(() {
                              student.assignedClass = className!;
                            });
                          }
                        } catch (e) {
                          _errorOccurred(context, e, "تعديل معلومات الطالب");
                        }
                      },
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
