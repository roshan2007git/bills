import 'package:cloud_firestore/cloud_firestore.dart';

class RegInfo {
  Future<int> fetchTotal() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('details')
              .doc('registrations')
              .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        int total = (data['total'] as num).toInt();
        return total;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<int> fetchTotalinsti() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('details')
              .doc('registrations')
              .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        int total = (data['institution'] as num).toInt();
        return total;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, int>> fetchEventTotal() async {
    try {
      QuerySnapshot indisnapshot =
          await FirebaseFirestore.instance
              .collection('indiRegistrations')
              .get();

      QuerySnapshot instisnapshot =
          await FirebaseFirestore.instance
              .collection('instiRegistrations')
              .get();

      Map<String, int> eventCounts = {};

      for (var doc in indisnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var event = data['event'];

        if (event != null && event['name'] != null) {
          String name = event['name'];
          String? category = event['category'];
          if (name == 'stratagem') {
            eventCounts['$name-$category'] =
                (eventCounts['$name-$category'] ?? 0) + 1;
          } else {
            eventCounts[name] = (eventCounts[name] ?? 0) + 1;
          }
        }
      }

      for (var doc in instisnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var events = data['events'];
        for (var event in events) {
          if (event != null && event['name'] != null) {
            String name = event['name'];
            String? category = event['category'];
            if (name == 'stratagem') {
              eventCounts['$name-$category'] =
                  (eventCounts['$name-$category'] ?? 0) + 1;
            } else {
              eventCounts[name] = (eventCounts[name] ?? 0) + 1;
            }
          }
        }
      }

      return eventCounts;
    } catch (e) {
      return {};
    }
  }
}
