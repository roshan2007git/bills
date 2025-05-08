import 'package:cloud_firestore/cloud_firestore.dart';

class Log {
  Future<void> logdata(username, data) async {
    DateTime now = DateTime.now();
    String date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    await FirebaseFirestore.instance
        .collection('logs')
        .doc(now.toIso8601String())
        .set({'user': username, 'data': data, 'date': date, 'time': time});
  }
}
