
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ultimate_task_by_studio/misc/errors.dart';
import 'package:ultimate_task_by_studio/misc/show_alert_dialog.dart';

Future<void> showExceptionAlertDialog(
    BuildContext context, {
      @required String title,
      @required Exception exception,
    }) =>
    showAlertDialog(
      context,
      title: title,
      content: _message(exception),
      defaultActionText: 'OK',
    );

String _message(Exception exception) {
  if (exception is FirebaseException) {
    return errorsCheck(exception.message);
  }
  if (exception is PlatformException) {
    return "Нет интернет-соединения.";
  }
  print(exception.toString());
  return exception.toString();
}
