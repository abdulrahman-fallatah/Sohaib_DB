import 'package:flutter/material.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';
import 'package:sohaib_db/pages/display_page2.dart';

class DisplayPage1 extends StatefulWidget {
  final StudentDao studentDao;
  final List<ClassRoom> classroomList;
  final List<Student> studentList;

  const DisplayPage1({
    super.key,
    required this.classroomList,
    required this.studentList,
    required this.studentDao,
  });

  @override
  State<DisplayPage1> createState() => _DisplayPage1State();
}

class _DisplayPage1State extends State<DisplayPage1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final StudentDao studentDao = widget.studentDao;
    List<ClassRoom> classroomList = widget.classroomList;
    List<Student> studentList = widget.studentList;

    return Scaffold(
      appBar: AppBar(title: Text("عرض الطلاب")),
      body: Column(
        children: [
          Card(
            child: ListTile(
              title: Text(
                "جميع الفصول",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: .center,
              ),
              leading: CircleAvatar(
                child: Text(
                  Validators().convertToEasternArabicNumbers("0"),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              trailing: Column(
                mainAxisSize: .min,
                children: [
                  Text(
                    "عدد الطلاب",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    Validators().convertToEasternArabicNumbers(
                      "${studentList.length}",
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPage2(studentList: studentList),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: classroomList.length,
              itemBuilder: ((context, i) {
                final className = classroomList[i].className;
                return Card(
                  child: ListTile(
                    title: Text(
                      "الفصل: $className",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: .center,
                    ),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPage2(
                          studentList: studentDao.getStudentsByClass(
                            classroomList[i].className!,
                          ),
                        ),
                      ),
                    ),
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
