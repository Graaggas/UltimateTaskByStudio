import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:ultimate_task_by_studio/misc/constants.dart';
import 'package:ultimate_task_by_studio/misc/converts.dart';
import 'package:ultimate_task_by_studio/misc/show_exception_dialog.dart';
import 'package:ultimate_task_by_studio/misc/show_message.dart';
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
    showMessage(
        context, isFinalDeleting ? "Задача завершена" : "Задача удалена");

    //! await убираем
    database.deleteTask(task);
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

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context, String user) async {
    // final didRequestSignOut = await showAlertDialog(
    //   context,
    //   title: 'Logout',
    //   content: 'Выйти из учетной записи "$user"?',
    //   cancelActionText: 'Отмена',
    //   defaultActionText: 'Выход',
    // );
    // if (didRequestSignOut == true) {
    //   _signOut(context);
    // }
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Logout",
      desc: "Выйти из учетной записи $user?",
      buttons: [
        DialogButton(
          child: Text(
            "Отмена",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          color: Colors.red,
          child: Text(
            "Выход",
            style: TextStyle(color: Colors.white, fontSize: 20),
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

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
            Text(
              isSwitched ? "Завершенные" : "Текущие задачи",
              style: GoogleFonts.alice(
                textStyle: TextStyle(color: Colors.black87, fontSize: 18),
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
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                ),
                DialogButton(
                  color: Colors.red,
                  child: Text(
                    "Удалить",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    final database =
                    Provider.of<Database>(context, listen: false);
                    database.deleteAllDone();
                    showMessage(context, "Завершенные задачи удалены");
                    Navigator.of(context).pop(true);
                  },
                  width: 120,
                )
              ],
            ).show();
          }
          // final finalDeleting = await showAlertDialog(context,
          //     title: "Удаление задач",
          //     content: "Удалить все задачи?",
          //     defaultActionText: "Удалить",
          //     cancelActionText: "Отмена");

          // if (finalDeleting == true) {
          //
          // }
        },
        backgroundColor: Color(myRedColor),
        child: Icon(
          Icons.delete_sharp,
          color: Colors.black,
        ),
      ),
      body: _buildContexts(context),
    );
  }

  List<Dismissible> getChildren(List tasks) {
    final children = tasks
        .map((task) => Dismissible(
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
      key: Key('task-${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) =>
          _delete(context, task, isSwitched ? true : false),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: TaskListTile(
          context: context,
          task: task,
          onTap: () => EditTaskPage.show(context, task: task),
        ),
      ),
    ))
        .toList();


    return children;
  }

  Widget _buildContexts(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Task>>(
      stream: database.tasksStream(),
      builder: (context, snapshot) {
        final tasks = snapshot.data;
        if (snapshot.hasData) {
          final List<Task> doneTasks = [];
          final List<Task> undoneTasks = [];

          tasks.forEach((element) {
            if (element.isDeleted == false) {

              undoneTasks.add(element);
            } else {
              doneTasks.add(element);
            }
          });


          undoneTasks.forEach((element) {
            if (element.doingDate.isBefore(DateTime.now())) {
              element.doingDate = DateTime.now();
            }
          });

          undoneTasks.sort((a, b) => a.doingDate.compareTo(b.doingDate));
          doneTasks.sort((a, b) => a.doingDate.compareTo(b.doingDate));

          switch (isSwitched) {
            case true:
              if (doneTasks.isNotEmpty) {
                final children = getChildren(doneTasks);
                isAnythingForDone = true;
                return ListView(children: children);
              } else {
                isAnythingForDone = false;
              }
              break;
            case false:
              if (undoneTasks.isNotEmpty) {
                final children = getChildren(undoneTasks);


                return ListView(children: children);
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
}
