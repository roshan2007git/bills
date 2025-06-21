import 'package:bills/pages/individual.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditDetailsIndi extends StatefulWidget {
  final Map<String, dynamic> data;
  final User currentUser;
  final String uid;
  final int? teammateIndex; // nullable: null for solo, index for team
  final String eventbackup;

  const EditDetailsIndi({
    super.key,
    required this.data,
    required this.currentUser,
    required this.uid,
    this.teammateIndex,
    required this.eventbackup,
  });

  @override
  State<EditDetailsIndi> createState() => _EditDetailsIndiState();
}

class _EditDetailsIndiState extends State<EditDetailsIndi> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController dobController;

  bool get isTeam => widget.teammateIndex != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers first (safe default)
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    dobController = TextEditingController();

    if (isTeam) {
      final teammate =
          widget.data['event']?['teammates']?[widget.teammateIndex!] ?? {};
      nameController.text = teammate['name'] ?? '';
      phoneController.text = teammate['phoneNumber'] ?? '';
      emailController.text = teammate['email'] ?? '';
      dobController.text = teammate['dateOfBirth'] ?? '';
    } else {
      nameController.text = widget.data['fName'] ?? '';
      phoneController.text = widget.data['phoneNumber'] ?? '';
      emailController.text = widget.data['email'] ?? '';
      dobController.text = widget.data['dateOfBirth'] ?? '';
    }
  }

  Future<void> _updateDetails() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(
            'indiRegistrations',
          ) // Ensure correct collection name here
          .doc(widget.uid);

      if (isTeam) {
        List<dynamic> teammates = List.from(widget.data['event']['teammates']);

        if (widget.teammateIndex! < teammates.length) {
          teammates[widget.teammateIndex!] = {
            'name': nameController.text.trim(),
            'phoneNumber': phoneController.text.trim(),
            'email': emailController.text.trim(),
            'dateOfBirth': dobController.text.trim(),
          };

          await docRef.update({'event.teammates': teammates});
        } else {
          throw Exception("Invalid teammate index");
        }
      } else {
        await docRef.update({
          'fName': nameController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'dateOfBirth': dobController.text.trim(),
        });
      }

      final updatedSnapshot = await docRef.get();
      final updatedData = updatedSnapshot.data();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Details updated successfully')));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TeamInfo(
                currentUser: widget.currentUser,
                data: updatedData!,
                uid: "T25N${widget.uid}",
                event: widget.eventbackup,
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
          title: const Text(
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
