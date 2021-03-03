import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:ultimate_task_by_studio/misc/constants.dart';
import 'package:ultimate_task_by_studio/misc/converts.dart';
import 'package:ultimate_task_by_studio/misc/show_alert_dialog.dart';
import 'package:ultimate_task_by_studio/misc/show_exception_dialog.dart';
import 'package:ultimate_task_by_studio/misc/show_message.dart';
import 'package:ultimate_task_by_studio/mobx/amount.dart';
import 'package:ultimate_task_by_studio/models/task.dart';
import 'package:ultimate_task_by_studio/screens/tasks/add_task_page.dart';
import 'package:ultimate_task_by_studio/screens/tasks/edit_task_page.dart';
import 'package:ultimate_task_by_studio/screens/tasks/empty_content.dart';
import 'package:ultimate_task_by_studio/screens/tasks/task_list_title.dart';
import 'package:ultimate_task_by_studio/service/auth.dart';
import 'package:ultimate_task_by_studio/service/database.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

Future<void> _delete(
    BuildContext context, Task task, bool isFinalDeleting) async {
  try {
    final database = Provider.of<Database>(context, listen: false);
    // showMessage(
    //     context, isFinalDeleting ? "Задача завершена" : "Задача удалена");

    //! await убираем
    database.deleteTask(task);
    final amount = Provider.of<Amount>(context, listen: false);
    amount.decrement();
  } on FirebaseException catch (e) {
    showExceptionAlertDialog(context, title: "Operation failed", exception: e);
  }
}

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool isSwitched = false;
  bool isAnythingForDone = false;

  List<Task> tasksToday = [];
  List<Task> tasksTomorrow = [];
  List tasksFuture = [];

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context, String user) async {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Logout",
      desc: "Выйти из учетной записи $user?",
      buttons: [
        DialogButton(
          child: Text(
            "Отмена",
            style: GoogleFonts.alice(
              textStyle: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          color: Colors.red,
          child: Text(
            "Выход",
            style: GoogleFonts.alice(
              textStyle: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          onPressed: () {
            _signOut(context);
            Navigator.of(context).pop(true);
          },
          width: 120,
        )
      ],
    ).show();
  }

  Future<int> getAmount() async{
    final database =  Provider.of<Database>(context, listen: false);
    return database.getTasksLength();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final amount = Provider.of<Amount>(context, listen: false);

    getAmount().then((value) => amount.getStartAmount(value));



    return Scaffold(
      backgroundColor: Color(myBackgroundColor),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(myBackgroundColor),
        title: Column(
          children: [
            Text(
              'Ultimate Task',
              style: GoogleFonts.alice(
                textStyle: TextStyle(color: Colors.black, fontSize: 22),
              ),
            ),
            Observer(
              builder: (_) => Text(
                isSwitched ? "Завершенные" : "Текущие задачи (${amount.value})",
                style: GoogleFonts.alice(
                  textStyle: TextStyle(color: Colors.black87, fontSize: 22),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          Switch(
              // inactiveTrackColor: Color(myMintColor),
              inactiveThumbColor: Color(myBackgroundColor),
              inactiveTrackColor: Color(myBlackLightColor),
              activeColor: Color(myBlueLightColor),
              activeTrackColor: Color(myBlackLightColor),
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = !isSwitched;
                });
              }),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () => _confirmSignOut(context, auth.currentUser.email),
          ),
        ],
      ),
      floatingActionButton: !isSwitched
          ? FloatingActionButton(
              backgroundColor: Color(myBlackLightColor),
              child: Icon(Icons.add),
              onPressed: () => AddTaskPage.show(context),
            )
          : FloatingActionButton(
              onPressed: () async {
                if (isAnythingForDone) {
                  Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "",
                    desc: "Удалить завершенные задачи?",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Отмена",
                          style: GoogleFonts.alice(
                            textStyle:
                                TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        width: 120,
                      ),
                      DialogButton(
                        color: Colors.red,
                        child: Text(
                          "Удалить",
                          style: GoogleFonts.alice(
                            textStyle:
                                TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                        onPressed: () {
                          final database =
                              Provider.of<Database>(context, listen: false);
                          database.deleteAllDone();
                          // showMessage(context, "Завершенные задачи удалены");
                          Navigator.of(context).pop(true);
                        },
                        width: 120,
                      )
                    ],
                  ).show();
                }
              },
              backgroundColor: Color(myRedColor),
              child: Icon(
                Icons.delete_sharp,
                color: Colors.black,
              ),
            ),
      body: _buildContexts(context, database),
    );
  }

  Widget _buildContexts(BuildContext context, Database database) {


    return StreamBuilder<List<Task>>(
      stream: database.tasksStream(),
      builder: (context, snapshot) {
        final tasks = snapshot.data;


        var indexTomorrow = 0;
        bool flagTommorow = false;
        bool flagFuture = false;
        var indexFuture = 0;

        if (snapshot.hasData) {
          final List<Task> doneTasks = [];
          final List<Task> undoneTasks = [];

          //сортировка списка
          tasks.sort((a, b) => a.doingDate.compareTo(b.doingDate));


          tasks.forEach((element) {
            if (element.isDeleted == false) {
              undoneTasks.add(element);

            } else {
              doneTasks.add(element);
            }
          });



          var now = DateTime.now();
          var tomorrow = now.add(new Duration(days: 1));
          var nextDayAfterTomorrow = now.add(new Duration(days: 2));

          print('~~ today is ${convertFromDateTimeToString(now)}');
          print('~~ tomorrow is ${convertFromDateTimeToString(tomorrow)}');
          print(
              '~~ newtDayAfterTomorrow is ${convertFromDateTimeToString(nextDayAfterTomorrow)}');
          Duration diff;

          // undoneTasks.forEach((element)
          for (int i = 0; i < undoneTasks.length; i++) {
            Task element = undoneTasks[i];
            print("\n\tindex = $i");

            /*просроченные задачи выставляем в "сегодня"*/
            if (element.doingDate.isBefore(now)) {
              element.doingDate = now;
            }

            print(
                "\x1B[33m \t\tday is ${convertFromDateTimeToString(element.doingDate)}\x1B[0m");
            diff = element.doingDate.difference(nextDayAfterTomorrow);
            print("~ NextDayAfterTomorrow diff is ${diff.inDays}");

            if (diff.inDays == -1) {
              // tasksTomorrow.add(element);
              if (flagTommorow == false) {
                indexTomorrow = i;
                flagTommorow = true;
                print(
                    "\t\t\t indexTomorrow = $indexTomorrow / flagTomorrow = $flagTommorow");
              }

              print(
                  "\x1B[31m /tomorrow/ = ${convertFromDateTimeToString(element.doingDate)}\x1B[0m");
              continue;
            }

            if (element.doingDate.isBefore(tomorrow)) {
              print(
                  "\x1B[36m /today/ = ${convertFromDateTimeToString(element.doingDate)}\x1B[0m");
              //tasksToday.add(element);
            }

            if (element.doingDate.isAfter(tomorrow)) {
              print(
                  "\x1B[34m /future/ = ${convertFromDateTimeToString(element.doingDate)}\x1B[0m");
              // tasksFuture.add(element);
              if (flagFuture == false) {
                flagFuture = true;
                indexFuture = i;
                print(
                    "\t\t\t indexFuture = $indexFuture / flagFuture = $flagFuture");
              }

              print("\n");
            }
          }

          switch (isSwitched) {
            case true:
              if (doneTasks.isNotEmpty) {
                isAnythingForDone = true;
                return ListView.builder(
                    itemCount: doneTasks.length,
                    itemBuilder: (context, i) {
                      return dismissibleTask(doneTasks, i, context);
                    });
              } else {
                isAnythingForDone = false;
              }
              break;
            case false:
              if (undoneTasks.isNotEmpty) {
                return ListView.separated(
                  itemCount: undoneTasks.length,
                  itemBuilder: (context, i) {
                    // return Card(child: Text(undoneTasks[i].memo),);
                    return dismissibleTask(undoneTasks, i, context);
                  },
                  separatorBuilder: (context, i) {
                    if (indexTomorrow == i + 1) {
                      flagTommorow = false;
                      return dateSeparator("Завтра");
                    }
                    if (indexFuture == i + 1) {
                      flagFuture = false;
                      return dateSeparator("Предстоящие");
                    }
                    return Container();
                    // return dateSeparator("Завтра");
                  },
                );
              }
              break;
            default:
              break;
          }

          return !isSwitched
              ? EmptyContent()
              : EmptyContent(
                  title: 'Завершенные задачи',
                  message: '',
                );
        }
        if (snapshot.hasError) {
          return Center(child: Text('ERROR'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Dismissible dismissibleTask(List<Task> tasks, int i, BuildContext context) {
    var database = Provider.of<Database>(context, listen: false);
    return Dismissible(
      background: Container(
        color: Color(myBackgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
      // key: Key('task-${tasks[i].id}'),
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Внимание!",
                  style: GoogleFonts.alice(
                    color: Colors.red,
                    fontSize: 22,
                  ),
                ),
                content: Text(
                  "Удалить задачу?",
                  style: GoogleFonts.alice(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
                actions: <Widget>[
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    elevation: 4.0,
                    color: Colors.red,
                    clipBehavior: Clip.antiAlias,
                    // Add This
                    child: MaterialButton(
                        child: Text("Отмена",
                            style: GoogleFonts.alice(
                              color: Colors.white,
                              fontSize: 22,
                            )),
                        onPressed: () =>
                            Navigator.of(context).pop<bool>(false)),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    elevation: 4.0,
                    color: Colors.blue,
                    clipBehavior: Clip.antiAlias,
                    // Add This
                    child: MaterialButton(
                        child: Text("Удалить",
                            style: GoogleFonts.alice(
                              color: Colors.white,
                              fontSize: 22,
                            )),
                        onPressed: () {
                          //callbackChangeAmount();
                          Navigator.of(context).pop<bool>(true);
                        }),
                  ),
                ],
              );
            });
      },
      onDismissed: (direction) {
        // callbackChangeAmount();
        //TODO если добавить строку выше, то все работает, но страница обновляется дважды и элемент прыгает на своем месте.

        // Task deletingTask = Task(
        //   color: tasks[i].color,
        //   creationDate: DateTime.now(),
        //   doingDate: tasks[i].doingDate,
        //   id: tasks[i].id,
        //   isDeleted: tasks[i].isDeleted,
        //   lastEditDate: tasks[i].lastEditDate,
        //   memo: tasks[i].memo,
        //   outOfDate: tasks[i].outOfDate,
        // );
        // Scaffold.of(context).hideCurrentSnackBar();
        // Scaffold.of(context).showSnackBar(SnackBar(
        //   content: Text("Задача удалена"),
        //   duration: Duration(seconds: 2),
        //   action: SnackBarAction(
        //     label: "Отмена",
        //     onPressed: () {
        //       database.createTask(deletingTask);
        //
        //     },
        //   ),
        // ));
        //

        _delete(context, tasks[i], isSwitched ? true : false);
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: TaskListTile(
          context: context,
          task: tasks[i],
          onTap: () => EditTaskPage.show(context, task: tasks[i]),
        ),
      ),
    );
  }

  Padding dateSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Divider(
              thickness: 2,
              indent: 12,
              endIndent: 12,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.alice(
              textStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 2,
              indent: 12,
              endIndent: 12,
            ),
          ),
        ],
      ),
    );
  }
}
