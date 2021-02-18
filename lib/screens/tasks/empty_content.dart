import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyContent extends StatelessWidget {
  final String title;
  final String message;

  const EmptyContent({
    Key key,
    this.title = "Список задач пуст",
    this.message = "Добавьте новую задачу",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              title,
              style: GoogleFonts.alice(
                textStyle: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
          ),
          Center(
            child: Text(
              message,
              style: GoogleFonts.alice(
                textStyle: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
