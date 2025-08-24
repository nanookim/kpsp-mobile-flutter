// import 'package:flutter/material.dart';
// import 'package:another_flushbar/flushbar.dart';
// import '../services/child_service.dart';
// import 'child_form_screen.dart';

// class ChildProfileScreen extends StatefulWidget {
//   const ChildProfileScreen({super.key});

//   @override
//   State<ChildProfileScreen> createState() => _ChildProfileScreenState();
// }

// class _ChildProfileScreenState extends State<ChildProfileScreen> {
//   final ChildService _childService = ChildService();
//   Map<String, dynamic>? _child;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadChild();
//   }

//   Future<void> _loadChild() async {
//     setState(() => _isLoading = true);
//     try {
//       final children = await _childService.getChildren();
//       if (children.isNotEmpty) {
//         setState(() => _child = children.first);
//       } else {
//         setState(() => _child = null);
//       }
//     } catch (e) {
//       _showFlush("Gagal memuat data anak: $e", Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showFlush(String message, Color color) {
//     Flushbar(
//       message: message,
//       duration: const Duration(seconds: 3),
//       margin: const EdgeInsets.all(12),
//       borderRadius: BorderRadius.circular(12),
//       backgroundColor: color,
//       flushbarPosition: FlushbarPosition.TOP,
//     ).show(context);
//   }

//   Future<void> _navigateToForm({Map<String, dynamic>? child}) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChildFormScreen(child: child),
//       ),
//     );

//     if (result == true) {
//       _loadChild();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Profil Anak")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _child == null
//               ? Center(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _navigateToForm(),
//                     icon: const Icon(Icons.add),
//                     label: const Text("Tambah Data Anak"),
//                   ),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.blue.shade100,
//                         child: const Icon(Icons.person,
//                             size: 50, color: Colors.blue),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         _child!["name"],
//                         style: const TextStyle(
//                             fontSize: 22, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Jenis Kelamin: ${_child!["gender"]}",
//                         style:
//                             const TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Tanggal Lahir: ${_child!["date_of_birth"]}",
//                         style:
//                             const TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 30),
//                       ElevatedButton.icon(
//                         onPressed: () => _navigateToForm(child: _child),
//                         icon: const Icon(Icons.edit),
//                         label: const Text("Edit Profil Anak"),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }
