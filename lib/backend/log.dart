import 'package:cloud_firestore/cloud_firestore.dart';

class Log {
  Future<void> logdata(username, data) async {
    DateTime now = DateTime.now();
    await FirebaseFirestore.instance
        .collection('logs')
        .doc(now.toIso8601String())
        .set({'user': username, 'data': data});
  }
}
