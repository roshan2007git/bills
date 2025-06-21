import 'package:bills/pages/institutional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditDetailsInsti extends StatefulWidget {
  final Map<String, dynamic> data;
  final User currentUser;
  final String uid;
  final int? teammateIndex; // nullable: null for solo, index for team
  final int eventIndex;

  const EditDetailsInsti({
    super.key,
    required this.data,
    required this.currentUser,
    required this.uid,
    this.teammateIndex,
    required this.eventIndex,
  });

  @override
  State<EditDetailsInsti> createState() => _EditDetailsInstiState();
}

class _EditDetailsInstiState extends State<EditDetailsInsti> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController dobController;

  bool get isTeam => widget.teammateIndex != null;

  @override
  void initState() {
    super.initState();

    // Get the correct event inside data
    final events = widget.data['events'] as List<dynamic>;
    final event = events[widget.eventIndex] as Map<String, dynamic>;
    final participants = event['participants'] as List<dynamic>;

    if (isTeam) {
      final teammate = participants[widget.teammateIndex!] ?? {};
      nameController = TextEditingController(text: teammate['name'] ?? '');
      phoneController = TextEditingController(
        text: teammate['phoneNumber'] ?? '',
      );
      emailController = TextEditingController(text: teammate['email'] ?? '');
      dobController = TextEditingController(
        text: teammate['dateOfBirth'] ?? '',
      );
    }
  }

  Future<void> _updateDetails() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('instiRegistrations')
          .doc(widget.uid);

      // Get full copy of the data
      Map<String, dynamic> fullData = Map<String, dynamic>.from(widget.data);
      List<dynamic> events = List.from(fullData['events']);

      // Get the event we're updating
      if (widget.eventIndex >= events.length) {
        throw Exception("Invalid event index");
      }
      Map<String, dynamic> event = Map<String, dynamic>.from(
        events[widget.eventIndex],
      );

      // Get participants
      List<dynamic> participants = List.from(event['participants']);

      // Update participant
      if (widget.teammateIndex! >= participants.length) {
        throw Exception("Invalid participant index");
      }
      participants[widget.teammateIndex!] = {
        'name': nameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'dateOfBirth': dobController.text.trim(),
      };

      // Put participants back into event
      event['participants'] = participants;
      events[widget.eventIndex] = event;

      // Finally update the full 'events' field in Firestore
      await docRef.update({'events': events});

      final updatedSnapshot = await docRef.get();
      final updatedData = updatedSnapshot.data();

      final updatedEvent = updatedData?['events'][widget.eventIndex];
      final eventName = updatedEvent['name'];

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Details updated successfully')));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ParticipantInfo(
                currentUser: widget.currentUser,
                data: updatedEvent,
                event: eventName.toString().toUpperCase(),
                uid: "T24N${widget.uid}",
                eventidx: widget.eventIndex,
                fullData: updatedData!,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating details: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
          centerTitle: true,
          title: Text(
            "Edit Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: const [SizedBox(width: 55)],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Name", nameController),
                _buildTextField("Phone Number", phoneController),
                _buildTextField("Email", emailController),
                _buildTextField("Date of Birth", dobController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _updateDetails,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Update",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
