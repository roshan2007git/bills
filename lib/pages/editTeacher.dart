import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTeacher extends StatefulWidget {
  final Map<String, dynamic> data;
  final String uid; // UID of the document (e.g., T25Nxxxx)
  const EditTeacher({super.key, required this.data, required this.uid});

  @override
  State<EditTeacher> createState() => _EditTeacherState();
}

class _EditTeacherState extends State<EditTeacher> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;

  @override
  void initState() {
    super.initState();

    final teacher = widget.data;
    nameController = TextEditingController(text: teacher['name'] ?? '');
    emailController = TextEditingController(text: teacher['email'] ?? '');
    numberController = TextEditingController(
      text: teacher['number']?.toString() ?? '',
    );
  }

  Future<void> _updateTeacherDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('instiRegistrations')
          .doc(widget.uid)
          .update({
            'teacher': {
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'number': numberController.text.trim(),
            },
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher details updated successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            "Edit Teacher Details",
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
                _buildTextField("Email", emailController),
                _buildTextField("Phone Number", numberController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _updateTeacherDetails,
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
