import 'package:flutter/material.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';

class AddStudents extends StatefulWidget {
  final StudentDao studentDao;
  final List<ClassRoom> classroomList;
  const AddStudents({
    super.key,
    required this.studentDao,
    required this.classroomList,
  });

  @override
  State<AddStudents> createState() => _AddStudentsState();
}

class _AddStudentsState extends State<AddStudents> {
  late List<(TextEditingController, TextEditingController)> studentsCtrl;
  GlobalKey<FormState> _addStudentsKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    studentsCtrl = List.generate(
      2,
      (i) => (TextEditingController(), TextEditingController()),
    );    
  }

  @override
  void dispose() {
    studentsCtrl.forEach((e) {
      e.$1.dispose();
      e.$2.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StudentDao studentDao = widget.studentDao;
    final List<ClassRoom> classroomList = widget.classroomList;

    return Scaffold(
      appBar: AppBar(title: Text("إضافة طلاب متعددين")),
      floatingActionButton: FloatingActionButton(
        child: Text(
          "إضافة الجميع",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: .center,
        ),
        onPressed: () {
          if (_addStudentsKey.currentState!.validate()) {
            List<(String, String)> studentsToAdd = studentsCtrl
                .map((e) => (e.$1.text, e.$2.text))
                .toList();
            try {
              List<(String, String)> failedList = studentDao
                  .addMultipleStudents(studentsToAdd);
              if (failedList.isEmpty) {
                Messages().success(context, "تم إضافة جميع الطلاب بنجاح");
              } else if (failedList.length == studentsToAdd.length) {
                Messages().detailedError(
                  context,
                  failedList,
                  "لم يتم إضافة الطلاب، للتالي:",
                );
              } else {
                Messages().detailedError(
                  context,
                  failedList,
                  "تم إضافة الطلاب باستثناء التالي:",
                );
              }
            } catch (e) {
              Messages().errorOccurred(context, e, "إضافة الطلاب");
            }
          }
        },
      ),
      body: Form(
        key: _addStudentsKey,
        child: ListView(
          children: [
            ...List.generate(studentsCtrl.length, (i) {
              return Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: studentsCtrl[i].$1,
                      textInputAction: .next,
                      decoration: InputDecoration(
                        label: Text('اسم الطالب'),
                        hint: Text("الاسم"),
                      ),
                      autovalidateMode: .onUserInteraction,
                      validator: (val) {
                        if (val!.isEmpty) return "الحقل فارغ";
                        if (!Validators().onlyLetters(val))
                          return "اسم الطالب يجب أن يحتوي على حروف عربية فقط";
                        if (studentsCtrl.where((e) => e.$1.text.trim() == val.trim()
                        && e.$2.text == studentsCtrl[i].$2.text) .length > 1) {
                          return "الاسم مكرر";
                        }
                        return null;
                      },
                    ),
                  ),

                  DropdownMenuFormField(
                    controller: studentsCtrl[i].$2,
                    selectOnly: true,
                    label: Text("الفصل"),
                    dropdownMenuEntries: [
                      ...List.generate(classroomList.length, (i) {
                        return DropdownMenuEntry(
                          value: classroomList[i].className,
                          label: "${classroomList[i].className}",
                        );
                      }),
                    ],
                    onSelected: (val){
                      studentsCtrl[i].$2.text = val!;
                    },
                    autovalidateMode: .onUserInteraction,
                    validator: (val) {
                      if (val == null) return "الحقل فارغ";
                      return null;
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 30),

            ElevatedButton(
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  studentsCtrl.add((
                    TextEditingController(),
                    TextEditingController(),
                  ));
                });
              },
            ),
            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (studentsCtrl.length > 1) {
                    studentsCtrl[studentsCtrl.length - 1].$1.dispose();
                    studentsCtrl[studentsCtrl.length - 1].$2.dispose();
                    studentsCtrl.removeLast();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
