import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_task_by_studio/misc/converts.dart';
import 'package:ultimate_task_by_studio/misc/show_alert_dialog.dart';
import 'package:ultimate_task_by_studio/mobx/amount.dart';
import 'package:ultimate_task_by_studio/models/task.dart';
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

class TaskListTile extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final BuildContext context;
  final Function callback;


  TaskListTile({Key key, this.task, this.onTap, this.context, this.callback})
      : super(key: key);

  @override
  _TaskListTileState createState() => _TaskListTileState();
}

class _TaskListTileState extends State<TaskListTile> {
  DateTime selectedDate = DateTime.now();


  Future<void> _taskFlagDeleted(String uid, bool flag) async {
    final database = Provider.of<Database>(context, listen: false);

    // widget.callback();
    final taskNew = Task(
      color: widget.task.color,
      creationDate: widget.task.creationDate,
      doingDate: widget.task.doingDate,
      id: uid,
      isDeleted: flag,
      lastEditDate: widget.task.lastEditDate,
      memo: widget.task.memo,
      outOfDate: widget.task.outOfDate,
    );

    if (flag)
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          final amount = Provider.of<Amount>(context, listen: false);
          return AlertDialog(
            title: Text(
              "Внимание!",
              style: GoogleFonts.alice(
                color: Colors.red,
                fontSize: 22,
              ),
            ),
            content: Text(
              "Завершить задачу?",
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
                color: Colors.blue,
                clipBehavior: Clip.antiAlias,
                // Add This
                child: MaterialButton(
                    child: Text("Отмена",
                        style: GoogleFonts.alice(
                          color: Colors.white,
                          fontSize: 22,
                        )),
                    onPressed: () =>
                        Navigator.of(context).pop(false)),
              ),
              Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                elevation: 4.0,
                color: Colors.red,
                clipBehavior: Clip.antiAlias,
                // Add This
                child: MaterialButton(
                    child: Text("Завершить",
                        style: GoogleFonts.alice(
                          color: Colors.white,
                          fontSize: 22,
                        )),
                    onPressed: () {
                      amount.decrement();
                      database.createTask(taskNew);

                      Navigator.of(context).pop(true);
                    }),
              ),
            ],
          );
        });
    else {

      database.createTask(taskNew);
    }

  }

  selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

        final database = Provider.of<Database>(context, listen: false);

        final taskNew = Task(
          color: widget.task.color,
          creationDate: widget.task.creationDate,
          doingDate: selectedDate,
          id: widget.task.id,
          isDeleted: false,
          lastEditDate: widget.task.lastEditDate,
          memo: widget.task.memo,
          outOfDate: widget.task.outOfDate,
        );

        database.createTask(taskNew);
      });

    //widget.task.doingDate = Timestamp.fromDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    selectedDate = DateTime.fromMillisecondsSinceEpoch(
        widget.task.doingDate.millisecondsSinceEpoch * 1000);

    print(
        "/task_list_title/ doingDate = ${convertFromDateTimeToString(widget.task.doingDate)}");

    return Card(
      //margin: EdgeInsets.all(10),
      elevation: 6,
      color: Color(int.parse(widget.task.color)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            //16
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.lock_clock,
                  size: 16,
                ),
                // SvgPicture.asset(
                //   'assets/icons/clock.svg',
                //   color: Colors.black54,
                //   height: 15,
                //   width: 15,
                // ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  convertFromDateTimeToString(widget.task.doingDate),
                  style: GoogleFonts.alice(
                    //18
                    textStyle: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                Spacer(),
                !widget.task.isDeleted
                    ? InkWell(
                        child: Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                        onTap: () => selectDate(context),
                      )
                    : Container(),
                SizedBox(
                  width: 30,
                ),
                InkWell(
                    onTap: () {

                      !widget.task.isDeleted
                          ? _taskFlagDeleted(widget.task.id, true)
                          : _taskFlagDeleted(widget.task.id, false);
                    },
                    child: !widget.task.isDeleted
                        ? Icon(
                            Icons.done,
                            size: 18,
                          )
                        : Icon(Icons.refresh_outlined, size: 18,)),
              ],
            ),
          ),
          Divider(),
          InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: Text(
                  widget.task.memo,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: GoogleFonts.alice(
                    textStyle: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
