import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import '../services/child_service.dart';
import 'child_form_screen.dart';

class MainChildScreen extends StatefulWidget {
  const MainChildScreen({super.key});

  @override
  State<MainChildScreen> createState() => _MainChildScreenState();
}

class _MainChildScreenState extends State<MainChildScreen> {
  final ChildService _childService = ChildService();
  List<Map<String, dynamic>> children = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  // Tambahkan fungsi ini di dalam class _MainChildScreenState
  String calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return "-";

    try {
      final birthDate = DateTime.parse(birthDateString);
      final today = DateTime.now();

      int years = today.year - birthDate.year;
      int months = today.month - birthDate.month;
      int days = today.day - birthDate.day;

      if (days < 0) {
        final prevMonth = DateTime(today.year, today.month, 0);
        days += prevMonth.day;
        months -= 1;
      }

      if (months < 0) {
        months += 12;
        years -= 1;
      }

      String result = "";
      if (years > 0) result += "$years tahun ";
      if (months > 0) result += "$months bulan ";
      if (days > 0) result += "$days hari";

      return result.trim();
    } catch (e) {
      debugPrint("Error calculate age: $e");
      return "-";
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      // Lebih baik log error-nya
      debugPrint("Error parsing date: $e");
      return dateString;
    }
  }

  Future<void> _fetchChildren() async {
    setState(() => _loading = true);
    try {
      final data = await _childService.fetchChildren();
      setState(() => children = data);
    } catch (e) {
      _showFlushbar("Gagal memuat data anak: $e", Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showFlushbar(String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
    ).show(context);
  }

  Color _getAvatarColor(String? gender) {
    if (gender?.toLowerCase() == 'perempuan') {
      return const Color(0xFFF78B94);
    } else if (gender?.toLowerCase() == 'laki-laki') {
      return const Color(0xFF8B94F7);
    }
    return const Color(0xFFC38BF7);
  }

  IconData _getAvatarIcon(String? gender) {
    if (gender?.toLowerCase() == 'perempuan') {
      return Icons.girl_rounded;
    } else if (gender?.toLowerCase() == 'laki-laki') {
      return Icons.boy_rounded;
    }
    return Icons.person_rounded;
  }

  Future<void> _navigateToChildForm({Map<String, dynamic>? child}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildFormScreen(child: child)),
    );
    if (result == true) {
      _fetchChildren();
      if (child == null) {
        _showFlushbar("🎉 Anak berhasil ditambahkan!", Colors.green);
      } else {
        _showFlushbar("Anak berhasil diperbarui!", Colors.green);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Background Shape
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.45,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6F51E9), Color(0xFF9F7AEA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ),
          ),
          // Floating Abstract Shapes
          Positioned(
            top: 60,
            left: -80,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.25,
            right: -60,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF6F51E9),
                            ),
                          ),
                        )
                      : children.isEmpty
                      ? _buildEmptyState()
                      : _buildChildList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToChildForm(),
        backgroundColor: const Color(0xFF6F51E9),
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
        elevation: 6,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Daftar Anak",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Aksi notifikasi
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada data anak 😔",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final String? gender = child['gender'];
        return GestureDetector(
          onTap: () => _navigateToChildForm(child: child),
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 25.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getAvatarColor(gender),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getAvatarColor(gender).withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getAvatarIcon(gender),
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Lahir: ${_formatDate(child['date_of_birth'])}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Usia: ${calculateAge(child['date_of_birth'])}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: Colors.blue.shade600,
                      size: 28,
                    ),
                    onPressed: () => _navigateToChildForm(child: child),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
