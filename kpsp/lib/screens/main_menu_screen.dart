import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:kpsp/screens/GambarScreen.dart';
import 'package:kpsp/screens/GrafikScreen.dart';
import 'package:kpsp/screens/PilihAnakScreen.dart';
import 'package:kpsp/screens/SkriningRiwayatScreen.dart';
import 'package:kpsp/screens/child_form_screen.dart';
import 'package:kpsp/screens/kuisoner_screen.dart';
import 'package:kpsp/screens/main_child_screen.dart';
import 'package:kpsp/screens/profile_screen.dart';
import 'package:kpsp/services/child_service.dart';
import 'package:kpsp/services/set_pertanyaan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color primary = Color(0xFF4B0082);
  static const Color primaryLight = Color(0xFF6F51E9);
  static const Color background = Color(0xFFF7F9FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textGrey = Color(0xFF7F8C8D);
}

class MainMenuScreen extends StatefulWidget {
  final bool showLoginSuccess;
  const MainMenuScreen({super.key, this.showLoginSuccess = false});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String? fullName;
  String? userEmail;
  String? childName = "Dina";
  int? childAge = 5;
  String? lastScreening = "Normal";
  List<Map<String, dynamic>>? screenings;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    if (widget.showLoginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        final name = prefs.getString('userName') ?? "Pengguna";

        Flushbar(
          message: "🎉 Login berhasil, selamat datang $name!",
          backgroundColor: AppColors.primaryLight,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          flushbarPosition: FlushbarPosition.TOP,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        ).show(context);
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('userName') ?? "Pengguna";
      userEmail = prefs.getString('userEmail') ?? "-";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildChildCard(),
                  const SizedBox(height: 32),
                  const Text(
                    "Pilihan Fitur",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Wrap GridView with SizedBox to avoid overflow
                  SizedBox(
                    height: screenHeight * 0.4, // adjust height as needed
                    child: _buildMenuGrid(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(fullName: fullName, userEmail: userEmail),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Deteksi Dini Tumbuh Kembang Anak",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Selamat Datang, ${fullName ?? "Pengguna"}!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_rounded, size: 45, color: AppColors.card),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName ?? "Pengguna",
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userEmail ?? "-",
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _MenuItem(
          icon: Icons.person_rounded,
          label: "Data Anak",
          color: AppColors.primary,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MainChildScreen()),
            );
            if (result != null && result == true) {}
          },
        ),
        _MenuItem(
          icon: Icons.note_alt_rounded,
          label: "Pemeriksaan",
          color: const Color(0xFF6495ED),
          onTap: () {
            if (childName == null) {
              _showFillChildDataDialog(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PilihAnakScreen()),
              );
            }
          },
        ),
        _MenuItem(
          icon: Icons.assignment_rounded,
          label: "Hasil Pemeriksaan",
          color: const Color(0xFFFFA07A),
          onTap: () {
            if (childName == null) {
              _showFillChildDataDialog(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SkriningRiwayatScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  void _showFillChildDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Lengkapi Data Anak",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "Anda harus mengisi data anak terlebih dahulu untuk menggunakan fitur ini.",
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Nanti",
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChildFormScreen()),
              );
              if (result != null && result == true) {
                setState(() {
                  childName = "Dina";
                  childAge = 5;
                  lastScreening = "Normal";
                });
              }
            },
            child: const Text(
              "Isi Sekarang",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
