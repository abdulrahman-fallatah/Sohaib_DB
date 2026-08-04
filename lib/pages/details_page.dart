import 'package:flutter/material.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';

class DetailsPage extends StatefulWidget {
  final Student student;
  const DetailsPage({super.key, required this.student});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final StudentDao studentDao = StudentDao(DatabaseManager.db);  

  @override
  Widget build(BuildContext context) {
    final Student student = widget.student;
    final List<Map<String, dynamic>> details = studentDao.getStudentAttendanceDetails(student.studentID.toString());
    return  Scaffold(
      appBar: AppBar(title: Text("تفاصيل الطالب")),
      body: Directionality(
        textDirection: .rtl,
        child: ListView(children: [
          Card(
            color: Colors.amber,
            child: ListTile(
              title: Text("اسم الطالب: ${student.fullName}", style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text("الفصل: ${student.assignedClass}", style: Theme.of(context).textTheme.titleMedium),
              trailing: Row(                
                mainAxisSize: .min,
                spacing: 10,
                children: [
                Column(
                  mainAxisAlignment: .center,
                  children: [
                  Text("أيام الحضور", style: Theme.of(context).textTheme.bodySmall),
                  Text(Validators().convertToEasternArabicNumbers(student.presentDays.toString()), style: Theme.of(context).textTheme.bodySmall),
                ],),
                Column(
                  mainAxisAlignment: .center,
                  children: [
                  Text("أيام الغياب", style: Theme.of(context).textTheme.bodySmall),
                  Text(Validators().convertToEasternArabicNumbers(student.absentDays.toString()), style: Theme.of(context).textTheme.bodySmall,),
                ],),
              ],),
            )
          ),
          SizedBox(height: 50,),
          
          DataTable(
            columns: [
              DataColumn(label: Text("رقم"), numeric: true,),
              DataColumn(label: Center(child: Text("التاريخ",))),
              DataColumn(label: Text("الحالة")),
            ],
            rows: [
              ...List.generate(details.length, (i){
                return DataRow(cells: [
                  DataCell(Text(Validators().convertToEasternArabicNumbers("${i+1}"))),
                  DataCell(Text(details[i]['date'])),
                  DataCell(Text(details[i]['status'])),
                ]);
              })
            ],
          )
        ],),
      ),
    );
  }
}