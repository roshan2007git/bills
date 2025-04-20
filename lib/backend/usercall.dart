import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallUser {
  Future<bool> approved(User currentUser) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        bool approval = userData['isApproved'];
        return approval;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> admin(User currentUser) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        bool admin = userData['isAdmin'];
        return admin;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> name(User currentUser) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String name = userData['name'];
        return name;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<List> bills(User currentUser) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        List bills = userData['bills'];
        return bills;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<double> amount(User currentUser) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        List bills = userData['bills'];
        double amount = 0;
        if (bills.isNotEmpty) {
          for (var bill in bills) {
            amount += bill['amount'];
          }
        } else {
          amount = 0;
        }
        return amount;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
