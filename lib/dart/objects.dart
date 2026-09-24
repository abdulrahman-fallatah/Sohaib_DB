import 'package:flutter/material.dart';

class ClassRoom {
  final int? classID;
  final String? className;

  ClassRoom({required this.classID, required this.className});

  factory ClassRoom.fromMap(Map map) {
    return ClassRoom(classID: map['class_id'], className: map['class_name']);
  }
}

class Student {
  int studentID;
  String fullName;
  String assignedClass;
  int presentDays;
  int absentDays;

  Student({
    required this.studentID,
    required this.fullName,
    required this.assignedClass,
    required this.presentDays,
    required this.absentDays,
  });

  factory Student.fromMap(Map map) {
    return Student(
      studentID: map['student_id'],
      fullName: map['fullName'] ?? "فارغ",
      assignedClass: map['class_name'] ?? "فارغ",
      presentDays: map['presentDays'] ?? 0,
      absentDays: map['absentDays'] ?? 0,
    );
  }
}

class Messages {
  void errorOccurred(BuildContext context, Object e, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("حدث خطأ أثناء $text"),
          content: Text("تفاصيل الخطأ:\n$e"),
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

  void detailedError(
    BuildContext context,
    List<(String, String)> detials,
    title,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            children: [
              ...List.generate(detials.length, (i) {
                return Text(
                  "الطالب: ${detials[i].$1}, الخطأ: ${detials[i].$2}.",
                );
              }),
            ],
          ),
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

  Future<bool> confirm(
    BuildContext context,
    String? title,
    String? content,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                title ?? 'تنبيه',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              content: Text(
                content ?? 'هل أنت متأكد',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              actions: [
                Row(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("نعم"),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text("إلغاء"),
                    ),
                  ],
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void success(BuildContext context, String? text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(text ?? "تمت العملية بنجاح"),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
