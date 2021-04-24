import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:ultimate_task_by_studio/misc/constants.dart';
import 'package:ultimate_task_by_studio/misc/converts.dart';
import 'package:ultimate_task_by_studio/misc/show_exception_dialog.dart';
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

  Future<int> getAmount() async {
    final database = Provider.of<Database>(context, listen: false);
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
              builder: (_) => FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  isSwitched ? "Завершенные" : "Текущие (${amount.value})",
                  style: GoogleFonts.alice(
                    textStyle: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
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

        var indexTomorrow = -1;

        bool flagTommorow = false;
        bool flagFuture = false;
        var indexFuture = -1;

        if (snapshot.hasData) {
          final List<Task> doneTasks = [];
          final List<Task> undoneTasks = [];

          final List<Task> undoneTasksToday = [];
          final List<Task> undoneTasksTomorrow = [];
          final List<Task> undoneTasksFuture = [];
          List<Task> finalUndoneTasks = [];

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

          Duration diff;

          // Просроченные задачи добавляются в "Сегодня"
          for (int i = 0; i < undoneTasks.length; i++) {
            Task element = undoneTasks[i];

            /*просроченные задачи выставляем в "сегодня"*/
            if (element.doingDate.isBefore(now)) {
              element.doingDate = now;
              // print(
              //     "// просрочка: ${element.memo}, дата: ${element.doingDate}");
              undoneTasksToday.add(element);
              print("today: ${element.memo}");
            }

            diff = element.doingDate.difference(nextDayAfterTomorrow);

            // final diffForToday = element.doingDate.difference(now).inDays;

            //заполняем сегодняшние задачи
            // if (diffForToday == 0) {
            //  //undoneTasksToday.add(element);
            // // continue;
            // }

            if (diff.inDays == -1) {
              print("// diff.inDays = ${diff.inDays}");
              print("tomorrow: ${element.memo}");
              if(!flagTommorow){
                indexTomorrow = i;
                flagTommorow = true;
              }

              undoneTasksTomorrow.add(element);
              // if (flagTommorow == false) {
              //   indexTomorrow = i;
              //   print("-- indexTomorrow = $indexTomorrow");
              //   flagTommorow = true;
              // }

              continue;
            }

            // if (element.doingDate.isBefore(tomorrow)) {
            //   print(
            //       "\x1B[36m /today/ = ${convertFromDateTimeToString(element.doingDate)}\x1B[0m");
            // }

            if (element.doingDate.isAfter(tomorrow)) {
              print("future: ${element.memo}");
              if (!flagFuture) {
                indexFuture = i;
                flagFuture = true;
              }

              undoneTasksFuture.add(element);
              // if (flagFuture == false) {
              //   flagFuture = true;
              //   indexFuture = i;
              //   print("//indexFuture = $indexFuture, task = ${element.memo}");
              // }

              print("\n");
              continue;
            }
          }

          //Формирование списков
          // print("tomorrow = $indexTomorrow, future = $indexFuture");
          // for (int i = 0; i < undoneTasks.length; i++) {
          //   if (indexTomorrow == -1) {
          //     print("\\\ today => [$i] ${undoneTasks[i].memo}");
          //     undoneTasksToday.add(undoneTasks[i]);
          //   }
          //   if (i < indexTomorrow) {
          //     print("\\\ today => [$i] ${undoneTasks[i].memo}");
          //     undoneTasksToday.add(undoneTasks[i]);
          //   }
          //   if (i >= indexTomorrow && i < indexFuture) {
          //     print("\\\ tomorrow =>[$i] ${undoneTasks[i].memo}");
          //     undoneTasksTomorrow.add(undoneTasks[i]);
          //   }
          //
          //   if (i >= indexFuture) {
          //     print("\\\ future =>[$i] ${undoneTasks[i].memo}");
          //     undoneTasksFuture.add(undoneTasks[i]);
          //   }
          // }

          //сортировка задач по цвету
          undoneTasksToday.sort((a, b) => a.color.compareTo(b.color));
          undoneTasksTomorrow.sort((a, b) => a.color.compareTo(b.color));
          undoneTasksFuture.sort((a, b) => a.color.compareTo(b.color));

          //формирование конечного цикла
          finalUndoneTasks = [
            ...undoneTasksToday,
            ...undoneTasksTomorrow,
            ...undoneTasksFuture
          ];

          //контрольный вывод cписка в консоль
          print("---------------");
          print("FOR TODAY");
          for (int i = 0; i < undoneTasksToday.length; i++) {
            print("[$i]. ${undoneTasksToday[i].memo}");
          }
          //контрольный вывод cписка в консоль
          print("---------------");
          print("FOR TOMORROW");
          for (int i = 0; i < undoneTasksTomorrow.length; i++) {
            print("[$i]. ${undoneTasksTomorrow[i].memo}");
          }
          //контрольный вывод cписка в консоль
          print("---------------");
          print("FOR FUTURE");
          for (int i = 0; i < undoneTasksFuture.length; i++) {
            print("[$i]. ${undoneTasksFuture[i].memo}");
          }
          //контрольный вывод cписка в консоль
          print("---------------");
          print("FOR ALL");
          for (int i = 0; i < finalUndoneTasks.length; i++) {
            print("[$i]. ${finalUndoneTasks[i].memo}");
          }

          print("---------------");
          print("Last List");
          for (int i = 0; i < finalUndoneTasks.length; i++) {
            print("[$i]. ${finalUndoneTasks[i].memo}");
          }

          print("--------------");
          print("indexFuture: $indexFuture");
          print("indexTomorrow: $indexTomorrow");
          print("--------------");

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
              if (finalUndoneTasks.isNotEmpty) {
                return ListView.separated(
                  itemCount: finalUndoneTasks.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: TaskListTile(
                        context: context,
                        task: finalUndoneTasks[i],
                        onTap: () => EditTaskPage.show(context,
                            task: finalUndoneTasks[i]),
                      ),
                    );
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
    // var database = Provider.of<Database>(context, listen: false);
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
                // title: Text(
                //   "Внимание!",
                //   style: GoogleFonts.alice(
                //     color: Colors.red,
                //     fontSize: 22,
                //   ),
                // ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildCardForDialog(tasks, i),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Удалить задачу?",
                      style: GoogleFonts.alice(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ],
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

  Card buildCardForDialog(List<Task> tasks, int i) {
    return Card(
      elevation: 6,
      color: Color(int.parse(tasks[i].color)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            //16
            padding:
                const EdgeInsets.only(left: 16.0, right: 16, top: 0, bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.lock_clock,
                  size: 16,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  convertFromDateTimeToString(tasks[i].doingDate),
                  style: GoogleFonts.alice(
                    //18
                    textStyle: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              child: Text(
                tasks[i].memo,
                maxLines: 3,
                overflow: TextOverflow.fade,
                softWrap: true,
                style: GoogleFonts.alice(
                  textStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding dateSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
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
                  fontSize: 16,
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
