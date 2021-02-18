
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Task {

  final String memo;

  final String id;

  DateTime creationDate;

  DateTime doingDate;

  DateTime lastEditDate;

  String color;

  bool outOfDate;

  bool isDeleted;

  Task({
    @required this.id,
    @required this.memo,
    @required this.color,
    @required this.creationDate,
    @required this.doingDate,
    @required this.isDeleted,
    @required this.lastEditDate,
    @required this.outOfDate,
  });

  factory Task.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    } else {
      final String memo = data['memo'];
      final String id = data['id'];
      final DateTime creationDate = data['creationDate'].toDate();
      final DateTime doingDate = data['doingDate'].toDate();
      final DateTime lastEditDate = data['lastEditDate'].toDate();
      final String color = data['color'];
      final bool outOfDate = data['outOfDate'];
      final bool isDeleted = data['isDeleted'];
      return Task(
        memo: memo,
        id: id,
        creationDate: creationDate,
        doingDate: doingDate,
        lastEditDate: lastEditDate,
        color: color,
        outOfDate: outOfDate,
        isDeleted: isDeleted,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'memo': memo,
      'id': id,
      'creationDate': Timestamp.fromDate(creationDate),
      'doingDate': Timestamp.fromDate(doingDate),
      'lastEditDate': Timestamp.fromDate(lastEditDate),
      'color': color,
      'outOfDate': outOfDate,
      'isDeleted': isDeleted,
    };
  }
}
