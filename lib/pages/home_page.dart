import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sohaib_db/daos/daos.dart';
import 'package:sohaib_db/dart/objects.dart';
import 'package:sohaib_db/dart/validators.dart';
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

  @override
  Widget build(BuildContext context) {
    final studentDao = widget.studentDao;
    final classDao = widget.classDao;
    List<Student> studentList = studentDao.getAllStudents();
    List<ClassRoom> classroomList = classDao.getAllClasses();
    List<Student> selectedStudents = [];

    return Scaffold(      
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: .center,
          children: [
            Text('x ', style: TextStyle(fontFamily: 'kfgqpc')),
            Text("قاعدة بيانات مركز صهيب الرومي"),
          ],
        ),       
      ),
      body: ListView(
        children: [
          SizedBox(height: 50),

          MaterialButton(
            color: Colors.amber,
            child: Column(
              children: [
                Icon(Icons.person_add_alt_outlined),
                Text("إضافة طالب"),
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
                    child: Directionality(
                      textDirection: .rtl,
                      child: SafeArea(
                        child: Form(
                          key: _addstudentKey,
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              TextFormField(
                                textDirection: .rtl,
                                textInputAction: .next,
                                decoration: InputDecoration(
                                  label: Text('اسم الطالب'),
                                  hint: Text("الاسم"),
                                ),
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

                              DropdownMenu(
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
                              ),
                              const SizedBox(height: 20),

                              FilledButton(
                                child: Text("تأكيد"),
                                onPressed: () {
                                  if (_addstudentKey.currentState!.validate()) {
                                    _addstudentKey.currentState!.save();
                                    try {
                                      studentDao.addStudentWithClass(
                                        name!,
                                        className!,
                                      );
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "تم إضافة الطالب بنجاح",
                                            textDirection: .rtl,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      _errorOccurred(context, e, "إضافة الطالب");
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 50),

          MaterialButton(
            color: Colors.amber,
            child: Column(
              children: [Icon(Icons.class_outlined), Text("إضافة فصل")],
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
                    child: Directionality(
                      textDirection: .rtl,
                      child: SafeArea(
                        child: Form(
                          key: _addclassKey,
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              TextFormField(
                                textDirection: .rtl,
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
                                      .convertToEasternArabicNumbers(
                                        val!.trim(),
                                      );
                                },
                                onFieldSubmitted: (val) {
                                  if (_addclassKey.currentState!.validate()) {
                                    _addclassKey.currentState!.save();
                                    try {
                                      classDao.addClass(val.trim());
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "تم إضافة الفصل بنجاح",
                                            textDirection: .rtl,
                                          ),
                                        ),
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
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "تم إضافة الفصل بنجاح",
                                            textDirection: .rtl,
                                          ),
                                        ),
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
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 50),

          MaterialButton(
            color: Colors.amber,
            child: Column(
              children: [Icon(Icons.people_outline), Text("عرض الطلاب")],
            ),
            onPressed: () {
              studentList = studentDao.getAllStudents();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisplayPage(studentList: studentList,),));
            },
          ),
          SizedBox(height: 50),

          MaterialButton(
            color: Colors.amber,
            child: Column(
              children: [
                Icon(Icons.person_search_outlined),
                Text("تحضير الطلاب"),
              ],
            ),
            onPressed: () {
              classroomList = classDao.getAllClasses();
              Navigator.of(context).push(MaterialPageRoute(builder: ((context) => AttendancePage1(classroomList: classroomList, studentList: studentList, studentDao: studentDao))));
            },
          ),
          SizedBox(height: 50),

          MaterialButton(
            color: Colors.amber,
            child: Column(
              children: [
                Icon(Icons.edit_outlined),
                Text("تعديل معلومات طالب"),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, setModalState){
                    return Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 15,
                    ),
                    child: Directionality(
                      textDirection: .rtl,
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
                                },);
                              },
                            ),
                            SizedBox(height: 10,),

                            DropdownMenu(
                              label: Text("الطالب"),
                              dropdownMenuEntries: [
                                ...List.generate(studentList.length, (i){
                                  return DropdownMenuEntry(
                                    value: studentList[i],
                                    label: studentList[i].fullName);
                                }),
                              ],
                              onSelected: (val){
                                setModalState((){
                                  selectedStudents.clear();
                                  selectedStudents.add(val!);
                                });
                              },
                            ),
                            SizedBox(height: 15),

                            FilledButton(
                              child: Text("تأكيد"),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdatePage(student: selectedStudents.first),));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  });
                },
              );
            },
          ),
          SizedBox(height: 50),

          MaterialButton(
            color: Colors.amber,
            child: Column(
              children: [Icon(Icons.person_remove_outlined), Text("حذف طالب")],
            ),
            onPressed: () {
              selectedStudents.clear();
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
                      child: Directionality(
                        textDirection: .rtl,
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
                                    studentList = studentDao.getStudentsByClass(
                                      val!,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                    
                              DropdownSearch<Student>.multiSelection(
                                compareFn: (i1, i2) => i1 == i2,
                                itemAsString: (item) {
                                  return "${item.assignedClass}\t${item.fullName}";
                                },
                                items: (filter, infiniteScrollProps) =>
                                    studentList,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'اختر الطالب/الطلاب المراد حذفهم',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                popupProps: MultiSelectionPopupProps.dialog(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    textDirection: .rtl,
                                    decoration: InputDecoration(
                                      hintText: "ابحث عن اسم الطالب",
                                      hintTextDirection: .rtl,
                                    ),
                                  ),
                                ),
                    
                                onSelected: (val) {
                                  setModalState((){
                                    selectedStudents.clear();
                                    selectedStudents = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                    
                              FilledButton(
                                onPressed: selectedStudents.isEmpty ? null : () async {                                
                                  bool? confirm = await showDialog<bool>(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: Text(
                                          "تنبيه!",
                                          style: TextStyle(color: Colors.red),
                                          textDirection: .rtl,
                                        ),
                                        content: Text(
                                          "سيتم حذف ${selectedStudents.length < 2 ? 'الطالب' : 'الطلاب'} من قاعدة البيانات:\n ${selectedStudents.map((e) => e.fullName + e.assignedClass)},\nهل أنت متأكد؟",
                                          textDirection: .rtl,
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
                                      studentDao.deleteStudent(selectedStudents);
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "تم حذف ${selectedStudents.length < 2 ? 'الطالب' : 'الطلاب'} بنجاح",
                                              textDirection: .rtl,
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        _errorOccurred(context, e, "حذف ${selectedStudents.length < 2 ? 'الطالب' : 'الطلاب'}");                                        
                                      }
                                    }
                                  }
                                },
                                child: Text("تأكيد"),
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
            },
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  void _errorOccurred(BuildContext context, Object e, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "حدث خطأ أثناء $text",
            textDirection: .rtl,
          ),
          content: Text(
            "تفاصيل الخطأ:\n$e",
            textDirection: .rtl,
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
}
