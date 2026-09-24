import 'package:flutter/material.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';
import 'package:sohaib_db/pages/details_page.dart';

class DisplayPage2 extends StatefulWidget {
  final List<Student> studentList;

  const DisplayPage2({super.key, required this.studentList});

  @override
  State<DisplayPage2> createState() => _DisplayPage2State();
}

class _DisplayPage2State extends State<DisplayPage2> {
  int? sortCol = 0;
  bool isAscending = true;  
  

  @override
  Widget build(BuildContext context){
    List<Student> studentList = widget.studentList;
    List<int> sequence = List.generate(studentList.length, (i) => i);    

      return Scaffold(
          appBar: AppBar(title: Text("عرض الطلاب")),
      body: studentList.length == 0 ?
      Center(child: Text("لا يوجد طلاب في هذا الفصل"),)
      : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: .horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  sortColumnIndex: sortCol,
                  sortAscending: isAscending,
                  columnSpacing: 22,
                  columns: [
                    DataColumn(label: Text("رقم"), numeric: true),
                    DataColumn(
                      label: Text("الاسم"),
                      onSort: (columnIndex, ascending) {
                        sortCol = columnIndex;
                        isAscending = ascending;
                        setState(() {
                          if (isAscending) {
                            studentList.sort(
                              (a, b) => a.fullName.compareTo(b.fullName),
                            );
                          } else {
                            studentList.sort(
                              (a, b) => b.fullName.compareTo(a.fullName),
                            );
                          }
                        });
                      },
                    ),
                    DataColumn(
                      label: Text("الفصل"),
                      onSort: (columnIndex, ascending) {
                        sortCol = columnIndex;
                        isAscending = ascending;
                        setState(() {
                          if (isAscending) {
                            studentList.sort(
                              (a, b) =>
                                  a.assignedClass.compareTo(b.assignedClass),
                            );
                          } else {
                            studentList.sort(
                              (a, b) =>
                                  b.assignedClass.compareTo(a.assignedClass),
                            );
                          }
                        });
                      },
                    ),
                    DataColumn(
                      label: Text("أيام الحضور"),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortCol = columnIndex;
                        isAscending = ascending;
                        setState(() {
                          if (isAscending) {
                            studentList.sort(
                              (a, b) => a.presentDays.compareTo(b.presentDays),
                            );
                          } else {
                            studentList.sort(
                              (a, b) => b.presentDays.compareTo(a.presentDays),
                            );
                          }
                        });
                      },
                    ),
                    DataColumn(
                      label: Text("أيام الغياب"),
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortCol = columnIndex;
                        isAscending = ascending;
                        setState(() {
                          if (isAscending) {
                            studentList.sort(
                              (a, b) => a.absentDays.compareTo(b.absentDays),
                            );
                          } else {
                            studentList.sort(
                              (a, b) => b.absentDays.compareTo(a.absentDays),
                            );
                          }
                        });
                      },
                    ),
                  ],
                  rows: [
                    ...List.generate(studentList.length, (i) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              Validators().convertToEasternArabicNumbers(
                                "${sequence[i] + 1}",
                              ),
                            ),
                          ),
                          DataCell(
                            Text(studentList[i].fullName),
                          onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailsPage(student: studentList[i]),
                                ),
                              );
                          },
                          ),
                          DataCell(Text(studentList[i].assignedClass)),
                          DataCell(
                            Center(
                              child: Text(
                                Validators().convertToEasternArabicNumbers(
                                  "${studentList[i].presentDays}",
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                Validators().convertToEasternArabicNumbers(
                                  "${studentList[i].absentDays}",
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },            
          )
      );
  }
}