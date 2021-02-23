import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ultimate_task_by_studio/misc/constants.dart';


void showMessage(BuildContext context, String message) {
  showFlash(
      context: context,
      persistent: true,
      duration: const Duration(seconds: 2),
      builder: (context, controller) {
        return Flash(
          backgroundColor: Colors.red[300],
          brightness: Brightness.light,
          barrierBlur: 3.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          boxShadows: kElevationToShadow[4],
          controller: controller,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            message: Center(
              child: Text(
                message,
                style: GoogleFonts.alice(
                  textStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            //showProgressIndicator: true,
            // primaryAction: TextButton(
            //   onPressed: () => controller.dismiss(),
            //   child: Text('ОТМЕНА', style: TextStyle(color: Colors.white)),
            // ),
          ),
        );
      });
}
