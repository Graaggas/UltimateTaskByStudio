import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_task_by_studio/misc/converts.dart';
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

  TaskListTile({Key key, this.task, this.onTap, this.context})
      : super(key: key);

  @override
  _TaskListTileState createState() => _TaskListTileState();
}

class _TaskListTileState extends State<TaskListTile> {
  DateTime selectedDate = DateTime.now();

  Future<void> _taskFlagDeleted(String uid, bool flag) async {
    final database = Provider.of<Database>(context, listen: false);

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

    await database.createTask(taskNew);
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.lock_clock),
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
                    textStyle: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Spacer(),
                !widget.task.isDeleted
                    ? InkWell(
                        child: Icon(Icons.calendar_today),
                        // child: SvgPicture.asset(
                        //   'assets/icons/calendar.svg',
                        //   color: Colors.black54,
                        //   height: 20,
                        //   width: 20,
                        // ),
                        onTap: () => selectDate(context),
                      )
                    : Container(),
                SizedBox(
                  width: 30,
                ),
                InkWell(
                    onTap: () => !widget.task.isDeleted
                        ? _taskFlagDeleted(widget.task.id, true)
                        : _taskFlagDeleted(widget.task.id, false),
                    // onTap: () => print("tapped"),
                    child: !widget.task.isDeleted
                        ? Icon(Icons.done)
                        //     ? SvgPicture.asset(
                        //   'assets/icons/done.svg',
                        //   color: Colors.black54,
                        //   height: 20,
                        //   width: 20,
                        // )
                        : Icon(Icons.refresh_outlined)
                    // SvgPicture.asset(
                    //   'assets/icons/fromtrash.svg',
                    //   color: Colors.black54,
                    //   height: 20,
                    //   width: 20,
                    // ),
                    ),
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
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: <Widget>[
      //     Padding(
      //       padding: const EdgeInsets.only(left: 8, right: 8),
      //       child: Row(
      //         children: <Widget>[
      //           InkWell(
      //             child: Row(
      //               children: [
      //                 Icon(
      //                   Icons.timer,
      //                   size: 15,
      //                 ),
      //                 SizedBox(
      //                   width: 5,
      //                 ),
      //                 Text(
      //                   "21.12.2021",
      //                   style: GoogleFonts.alice(
      //                     textStyle:
      //                         TextStyle(color: Colors.black, fontSize: 14),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             onTap: onTap,
      //           ),
      //           Spacer(),
      //           IconButton(icon: Icon(Icons.done), onPressed: () {}),
      //           IconButton(icon: Icon(Icons.calendar_today), onPressed: () {}),
      //         ],
      //       ),
      //     ),
      //     InkWell(
      //       onTap: onTap,
      //       child: Container(
      //         width: double.infinity,
      //         child: Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: Text(
      //             task.memo,
      //             maxLines: 3,
      //             overflow: TextOverflow.fade,
      //             softWrap: true,
      //             style: GoogleFonts.alice(
      //               textStyle: TextStyle(color: Colors.black, fontSize: 18),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
    // return ListTile(
    //   title: Text(task.memo),
    //   trailing: Icon(Icons.chevron_right),
    //   onTap: onTap,
    // );
  }
}
