import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_task_by_studio/mobx/amount.dart';
import 'package:uuid/uuid.dart';
import 'package:ultimate_task_by_studio/misc/constants.dart';
import 'package:ultimate_task_by_studio/misc/converts.dart';
import 'package:ultimate_task_by_studio/misc/show_message.dart';
import 'package:ultimate_task_by_studio/models/task.dart';
import 'package:ultimate_task_by_studio/service/database.dart';

class AddTaskPage extends StatefulWidget {
  final Database database;

  AddTaskPage({Key key, this.database}) : super(key: key);

  //* контекст берется из taskPage, потому как show запускается именно оттуда.
  static Future<void> show(
      BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  String uid = '';
  bool isColorCirclesVisible = false;
  Color currentColor = Colors.white;

  DateTime doingDate = DateTime.now();
  DateTime creationDate = DateTime.now();
  DateTime lastEditDate = DateTime.now();

  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  String _memo;

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit(String uid, BuildContext context) async {
    final amount = Provider.of<Amount>(context, listen: false);
    if (_validateAndSaveForm()) {
      final task = Task(
        color: convertColorToString(currentColor),
        creationDate: DateTime.now(),
        doingDate:
            selectedDate == DateTime.now() ? DateTime.now() : selectedDate,
        id: uid,
        isDeleted: false,
        lastEditDate: DateTime.now(),
        memo: _memo,
        outOfDate: false,
      );
      print(
          "/add_task_page/ doingDate = ${convertFromDateTimeToString(task.doingDate)}");
      //! await убираем

      widget.database.createTask(task);


      amount.increment();
      Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    uid = Uuid().v4();
    // selectedDate = convertFromTimeStampToString(doingDate);

    super.initState();
  }

  selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale("ru", "RU"),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print("==> selectedDate = $selectedDate");
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(myBackgroundColor),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0,
        backgroundColor: Color(myBackgroundColor),
        title: Text(
          "Новая задача",
          style: GoogleFonts.alice(
            textStyle: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () => selectDate(context),
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: () => _submit(uid, context),
          ),
        ],
      ),
      body: _buildContest(),
    );
  }

  Widget _buildContest() {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              _buildCardForMemo(),
              _buildContainerWithColorCircles()
            ],
          ),
        ),
      ),
    );
  }

  Container _buildContainerWithColorCircles() {
    return !isColorCirclesVisible
        ? Container()
        : Container(
            child: Card(
              elevation: 4,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildExpandableColorCircleField(),
              ),
            ),
          );
  }

  Card _buildCardForMemo() {
    return Card(
      elevation: 8,
      color: currentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16, left: 16),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      _buildTextFieldForMemo(),
      _buildArrowForExpanding(),
      // _buildExpandableColorCircleField(),
    ];
  }

  TextFormField _buildTextFieldForMemo() {
    return TextFormField(
      style: GoogleFonts.alice(
        textStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
      keyboardType: TextInputType.multiline,
      validator: (value) => value.isNotEmpty ? null : 'Введите текст задачи...',
      maxLines: null,
      cursorColor: Colors.red,
      textAlign: TextAlign.justify,
      onSaved: (value) => _memo = value,
      decoration: InputDecoration.collapsed(
        hintStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
        hintText: 'Текст новой задачи...',
      ),
    );
  }

  Container _buildArrowForExpanding() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
          !isColorCirclesVisible
              ? IconButton(
                  icon: Icon(Icons.arrow_drop_down),
                  onPressed: () {
                    setState(() {
                      isColorCirclesVisible = !isColorCirclesVisible;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.arrow_drop_up),
                  onPressed: () {
                    setState(() {
                      isColorCirclesVisible = !isColorCirclesVisible;
                    });
                  },
                ),
        ],
      ),
    );
  }

  Column _buildExpandableColorCircleField() {
    return Column(
      children: <Widget>[
        buildColorCircles(),
      ],
    );
  }

  Widget buildColorCircles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildExpandedCircleColor(Color(0xFF7389AE)),
        buildExpandedCircleColor(Color(0xFF81D2C7)),
        buildExpandedCircleColor(Colors.cyan[200]),
        buildExpandedCircleColor(Color(0xFFF87060)),
        buildExpandedCircleColor(Colors.white),
      ],
    );
  }

  Expanded buildExpandedCircleColor(Color myColor) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            currentColor = myColor;
          });
        },
        customBorder: CircleBorder(),
        child: Container(
          height: 30,
          width: 50,
          //margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              color: myColor,
              shape: BoxShape.circle),
        ),
      ),
    );
  }
}
