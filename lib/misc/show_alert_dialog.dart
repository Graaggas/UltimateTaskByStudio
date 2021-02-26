import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool> showAlertDialog(
  BuildContext context, {
  @required String title,
  @required String content,
  String cancelActionText,
  @required String defaultActionText,
}) {
  if (!Platform.isIOS) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            content: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 8,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Container(
                  child: Text(content,
                      style: GoogleFonts.alice(
                        color: Colors.black,
                        fontSize: 26,
                      )),
                ),
              ),
            ),
            actions: [
              if (cancelActionText != null)
                Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  elevation: 4.0,
                  color: Colors.red,
                  clipBehavior: Clip.antiAlias,
                  // Add This
                  child: MaterialButton(
                      child: Text(cancelActionText,
                          style: GoogleFonts.alice(
                            color: Colors.white,
                            fontSize: 22,
                          )),
                      onPressed: () => () => Navigator.of(context).pop(false)),
                ),
              Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                elevation: 4.0,
                color: Colors.blue,
                clipBehavior: Clip.antiAlias,
                // Add This
                child: MaterialButton(
                    child: Text(defaultActionText,
                        style: GoogleFonts.alice(
                          color: Colors.white,
                          fontSize: 22,
                        )),
                    onPressed: () => () => Navigator.of(context).pop(true)),
              ),
            ],
          );
        });

    // return showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(16.0))),
    //     contentPadding: EdgeInsets.only(top: 10.0),
    //     elevation: 4,
    //     title: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           title,
    //           style: GoogleFonts.alice(
    //             textStyle: TextStyle(color: Colors.black, fontSize: 24),
    //           ),
    //         ),
    //       ],
    //     ),
    //     content: Container(
    //       child: Padding(
    //         padding: const EdgeInsets.all(18.0),
    //         child: Container(
    //           child: FittedBox(
    //             fit: BoxFit.contain,
    //             child: Text(
    //               content,
    //               style: GoogleFonts.alice(
    //                 textStyle: TextStyle(color: Colors.black, fontSize: 18),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //     actions: <Widget>[
    //       if (cancelActionText != null)
    //         TextButton(
    //           child: Text(
    //             cancelActionText,
    //             style: GoogleFonts.alice(
    //               textStyle: TextStyle(color: Colors.red, fontSize: 24),
    //             ),
    //           ),
    //           onPressed: () => Navigator.of(context).pop(false),
    //         ),
    //       TextButton(
    //         child: Text(
    //           defaultActionText,
    //           style: GoogleFonts.alice(
    //             textStyle: TextStyle(color: Colors.blue, fontSize: 24),
    //           ),
    //         ),
    //         onPressed: () => Navigator.of(context).pop(true),
    //       ),
    //     ],
    //   ),
    // );
  }
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        if (cancelActionText != null)
          CupertinoDialogAction(
            child: Text(cancelActionText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        CupertinoDialogAction(
          child: Text(defaultActionText),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}
