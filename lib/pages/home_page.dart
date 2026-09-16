import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';
import 'package:sohaib_db/pages/add_students.dart';
import 'package:sohaib_db/pages/update_page.dart';
import 'attendance_page1.dart';
import 'display_page.dart';

class HomePage extends StatefulWidget {
  final StudentDao studentDao;
  final ClassDao classDao;

  const HomePage({super.key, required this.studentDao, required this.classDao});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _addstudentKey = GlobalKey<FormState>();
  final _addclassKey = GlobalKey<FormState>();
  String? name;
  String? className;
  List<Student> studentList = [];
  List<ClassRoom> classroomList = [];

  @override
  void initState() {
    super.initState();
    studentList = widget.studentDao.getAllStudents();
    classroomList = widget.classDao.getAllClasses();
    if (classroomList.isEmpty) {
      DatabaseManager().initClasses();
      classroomList = widget.classDao.getAllClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentDao = widget.studentDao;
    final classDao = widget.classDao;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: .center,
          children: [
            Text("قاعدة بيانات مركز صهيب الرومي"),
            Text(' x', style: TextStyle(fontFamily: 'kfgqpc')),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("حول البرنامج"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AboutDialog(
                        applicationName: "قاعدة بيانات مركز صهيب الرومي",
                        applicationVersion: "1.1.0",
                        applicationIcon: Image.asset(
                          "assets/icon/sohaib_logo.png",
                          width: 70,
                        ),
                        children: [
                          Image.asset(
                            "assets/icon/personal_logo.png",
                            width: 50,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),      
      body: Platform.isWindows
          ? _buildDesktopLayout(
              studentDao,
              classDao,
              studentList,
              classroomList,
            )
          : _buildAndroidLayout(
              studentDao,
              classDao,
              studentList,
              classroomList,
            ),
    );
  }

  Padding _buildDesktopLayout(
    StudentDao studentDao,
    ClassDao classDao,
    List<Student> studentList,
    List<ClassRoom> classroomList,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2,
        ),
        children: [
          _addStudentButton(studentDao, classroomList),
          _addClassButton(classDao),
          _showStudentsButton(studentDao),
          _recordAttendanceButton(studentDao, classDao, studentList),
          _updateStudentButton(studentDao, classroomList),
          _deleteStudentButton(studentDao, classroomList),
        ],
      ),
    );
  }

  Padding _buildAndroidLayout(
    StudentDao studentDao,
    ClassDao classDao,
    List<Student> studentList,
    List<ClassRoom> classroomList,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          SizedBox(height: 50),

          _addStudentButton(studentDao, classroomList),
          SizedBox(height: 50),

          _addClassButton(classDao),
          SizedBox(height: 50),

          _showStudentsButton(studentDao),
          SizedBox(height: 50),

          _recordAttendanceButton(studentDao, classDao, studentList),
          SizedBox(height: 50),

          _updateStudentButton(studentDao, classroomList),
          SizedBox(height: 50),

          _deleteStudentButton(studentDao, classroomList),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  ElevatedButton _addStudentButton(
    StudentDao studentDao,
    List<ClassRoom> classroomList,
  ) {
    return ElevatedButton(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.person_add_alt_outlined, size: 30),
          Text("إضافة طالب", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 15,
              ),
              child: SafeArea(
                child: Form(
                  key: _addstudentKey,
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      TextFormField(
                        textInputAction: .next,
                        decoration: InputDecoration(
                          label: Text('اسم الطالب'),
                          hint: Text("الاسم"),
                        ),
                        autovalidateMode: .onUserInteraction,
                        validator: (val) {
                          if (val!.isEmpty) return "الحقل فارغ";
                          if (!Validators().onlyLetters(val)) {
                            return "اسم الطالب يجب أن يحتوي على حروف عربية فقط";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          name = val!.trim();
                        },
                      ),
                      const SizedBox(height: 10),

                      DropdownMenuFormField(
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
                        onSelected: (val) {
                          className = val;
                        },
                        autovalidateMode: .onUserInteraction,
                        validator: (val) {
                          if (val == null) return "الحقل فارغ";
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      FilledButton(
                        child: Text("تأكيد"),
                        onPressed: () {
                          if (_addstudentKey.currentState!.validate()) {
                            _addstudentKey.currentState!.save();
                            try {
                              studentDao.addStudentWithClass(name!, className!);
                              _refreshStudents();
                              Navigator.of(context).pop();
                              Messages().success(
                                context,
                                "تم إضافة الطالب بنجاح",
                              );
                            } catch (e) {
                              _errorOccurred(context, e, "إضافة الطالب");
                            }
                          }
                        },
                      ),
                      SizedBox(height: 30),

                      FilledButton(
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            Icon(Icons.arrow_back),
                            Text("إضافة طلاب متعددين"),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddStudents(
                                studentDao: studentDao,
                                classroomList: classroomList,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  ElevatedButton _addClassButton(ClassDao classDao) {
    return ElevatedButton(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.class_outlined, size: 30),
          Text("إضافة فصل", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 15,
              ),
              child: SafeArea(
                child: Form(
                  key: _addclassKey,
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('عنوان الفصل'),
                          hint: Text("الفصل"),
                        ),
                        textInputAction: .done,
                        validator: (val) {
                          if (val!.isEmpty) return "الحقل فارغ";
                          return null;
                        },
                        onSaved: (val) {
                          className = Validators()
                              .convertToEasternArabicNumbers(val!.trim());
                        },
                        onFieldSubmitted: (val) {
                          if (_addclassKey.currentState!.validate()) {
                            _addclassKey.currentState!.save();
                            try {
                              classDao.addClass(val.trim());
                              _refreshClasses();
                              Navigator.of(context).pop();
                              Messages().success(
                                context,
                                "تم إضافة الفصل بنجاح",
                              );
                            } catch (e) {
                              _errorOccurred(context, e, "إضافة الفصل");
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        child: Text("تأكيد"),
                        onPressed: () {
                          if (_addclassKey.currentState!.validate()) {
                            _addclassKey.currentState!.save();
                            try {
                              classDao.addClass(className!);
                              _refreshClasses();
                              Navigator.of(context).pop();
                              Messages().success(
                                context,
                                "تم إضافة الفصل بنجاح",
                              );
                            } catch (e) {
                              _errorOccurred(context, e, "إضافة الفصل");
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  ElevatedButton _showStudentsButton(StudentDao studentDao) {
    return ElevatedButton(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.people_outline, size: 30),
          Text("عرض الطلاب", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                DisplayPage(studentList: studentDao.getAllStudents()),
          ),
        );
      },
    );
  }

  ElevatedButton _recordAttendanceButton(
    StudentDao studentDao,
    ClassDao classDao,
    List<Student> studentList,
  ) {
    return ElevatedButton(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.person_search_outlined, size: 30),
          Text("تحضير الطلاب", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => AttendancePage1(
              classroomList: classDao.getAllClasses(),
              studentList: studentList,
              studentDao: studentDao,
            )),
          ),
        );
      },
    );
  }

  ElevatedButton _updateStudentButton(
    StudentDao studentDao,
    List<ClassRoom> classroomList,
  ) {
    List<Student> studentList = [];
    List<Student> selectedStudents = [];
    return ElevatedButton(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.edit_outlined, size: 30),
          Text(
            "تعديل معلومات طالب",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 15,
                    right: 15,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        DropdownMenu(
                          label: Text("الفصل"),
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: "All",
                              label: "جميع الفصول",
                            ),
                            ...List.generate(classroomList.length, (i) {
                              return DropdownMenuEntry(
                                value: classroomList[i].className,
                                label: "${classroomList[i].className}",
                              );
                            }),
                          ],
                          onSelected: (val) {
                            setModalState(() {
                              if (val == "All") {
                                studentList = studentDao.getAllStudents();
                              } else {
                                studentList = studentDao.getStudentsByClass(
                                  val!,
                                );
                              }
                            });
                          },
                        ),
                        SizedBox(height: 10),

                        DropdownMenu(
                          label: Text("الطالب"),
                          dropdownMenuEntries: [
                            ...List.generate(studentList.length, (i) {
                              return DropdownMenuEntry(
                                value: studentList[i],
                                label: studentList[i].fullName,
                              );
                            }),
                          ],
                          onSelected: (val) {
                            setModalState(() {
                              selectedStudents.clear();
                              selectedStudents.add(val!);
                            });
                          },
                        ),
                        SizedBox(height: 15),

                        FilledButton(
                          child: Text("تأكيد"),
                          onPressed: selectedStudents.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => UpdatePage(
                                        student: selectedStudents.first,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  ElevatedButton _deleteStudentButton(
    StudentDao studentDao,
    List<ClassRoom> classroomList,
  ) {
    List<Student> studentList = [];
    List<Student> selectedStudents = [];
    return ElevatedButton(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.person_remove_outlined, size: 30),
          Text("حذف طالب", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 15,
                    right: 15,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        DropdownMenu(
                          label: Text("الفصل"),
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: "All",
                              label: "جميع الفصول",
                            ),
                            ...List.generate(classroomList.length, (i) {
                              return DropdownMenuEntry(
                                value: classroomList[i].className,
                                label: "${classroomList[i].className}",
                              );
                            }),
                          ],
                          onSelected: (val) {
                            if (val == "All") {
                              studentList = studentDao.getAllStudents();
                            } else {
                              studentList = studentDao.getStudentsByClass(val!);
                            }
                          },
                        ),
                        const SizedBox(height: 10),

                        DropdownSearch<Student>.multiSelection(
                          compareFn: (i1, i2) => i1 == i2,
                          itemAsString: (item) {
                            return "${item.assignedClass}\t${item.fullName}";
                          },
                          items: (filter, infiniteScrollProps) => studentList,
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'اختر الطالب/الطلاب المراد حذفهم',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          popupProps: MultiSelectionPopupProps.dialog(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "ابحث عن اسم الطالب",
                              ),
                            ),
                          ),

                          onSelected: (val) {
                            setModalState(() {
                              selectedStudents.clear();
                              selectedStudents = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        FilledButton(
                          onPressed: selectedStudents.isEmpty
                              ? null
                              : () async {
                                  bool? confirm = await showDialog<bool>(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: Text(
                                          "تنبيه!",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        content: Text(
                                          "سيتم حذف ${selectedStudents.length < 2 ? 'الطالب' : 'الطلاب'} من قاعدة البيانات:\n ${selectedStudents.map((e) => "${e.fullName} ${e.assignedClass}")},\nهل أنت متأكد؟",
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: .spaceEvenly,
                                            children: [
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text("نعم"),
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                ),
                                              ),
                                              FilledButton(
                                                child: Text("إلغاء"),
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    try {
                                      studentDao.deleteStudent(
                                        selectedStudents,
                                      );
                                      _refreshStudents();
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "تم حذف ${selectedStudents.length < 2 ? 'الطالب' : 'الطلاب'} بنجاح",
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        _errorOccurred(
                                          context,
                                          e,
                                          "حذف ${selectedStudents.length < 2 ? 'الطالب' : 'الطلاب'}",
                                        );
                                      }
                                    }
                                  }
                                },
                          child: Text("تأكيد"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _errorOccurred(BuildContext context, Object e, String text) {
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

  void _refreshStudents() {
    setState(() {
      studentList = widget.studentDao.getAllStudents();
    });
  }

  void _refreshClasses() {
    setState(() {
      classroomList = widget.classDao.getAllClasses();
    });
  }
}
