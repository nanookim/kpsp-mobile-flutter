import 'package:flutter/material.dart';
import 'package:kpsp/screens/signin_screen.dart';

// ================= PROFILE SCREEN =================
class ProfileScreen extends StatefulWidget {
  final String? childName;
  final int? childAge;
  final String? lastScreening;

  const ProfileScreen({
    super.key,
    this.childName,
    this.childAge,
    this.lastScreening,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String? _childName;
  late int? _childAge;
  late String? _lastScreening;

  @override
  void initState() {
    super.initState();
    _childName = widget.childName;
    _childAge = widget.childAge;
    _lastScreening = widget.lastScreening;
  }

  // ==== LOGOUT ====
  void _logout(BuildContext context) {
    // Clear data (simulasi)
    setState(() {
      _childName = null;
      _childAge = null;
      _lastScreening = null;
    });

    // Arahkan ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  // ==== EDIT PROFIL ====
  void _editProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(currentName: _childName, currentAge: _childAge),
      ),
    );

    // Jika ada data baru dari form, update state
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _childName = result['name'];
        _childAge = result['age'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              _childName ?? "Belum ada data",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _childAge != null ? "Usia: $_childAge tahun" : "Usia: -",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              "Hasil terakhir: ${_lastScreening ?? "-"}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Tombol Edit
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profil Anak"),
              onTap: () => _editProfile(context),
            ),

            // Tombol Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= EDIT PROFILE SCREEN =================
class EditProfileScreen extends StatefulWidget {
  final String? currentName;
  final int? currentAge;

  const EditProfileScreen({super.key, this.currentName, this.currentAge});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName ?? "");
    _ageController = TextEditingController(
      text: widget.currentAge?.toString() ?? "",
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil Anak")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Anak"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Usia Anak"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Usia wajib diisi";
                  if (int.tryParse(value) == null) return "Usia harus angka";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
