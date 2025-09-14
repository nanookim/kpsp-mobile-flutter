import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpsp/screens/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kpsp/theme/theme.dart';

// ================= PROFILE SCREEN =================
class ProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? userEmail;
  final String? childName;
  final int? childAge;
  final String? lastScreening;

  const ProfileScreen({
    super.key,
    this.childName,
    this.childAge,
    this.lastScreening,
    this.fullName,
    this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  // ==== LOGOUT ====
  void _logout(BuildContext context) async {
    // 🔹 Hapus data login tersimpan (kalau ada)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 🔹 Arahkan ke SignInScreen & hapus semua route sebelumnya
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false, // ⬅️ semua route sebelumnya dihapus
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar user
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF9C27B0).withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Nama lengkap dari akun
                        Text(
                          widget.fullName ?? "Pengguna",
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Email user
                        Text(
                          widget.userEmail ?? "-",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Tombol Edit dan Logout
                        const SizedBox(height: 10),
                        _buildProfileButton(
                          icon: Icons.logout,
                          title: "Logout",
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk menampilkan informasi
  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(value, style: GoogleFonts.montserrat(color: Colors.black87)),
        ],
      ),
    );
  }

  // Widget pembantu untuk tombol
  Widget _buildProfileButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: lightColorScheme.primary,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: lightColorScheme.primary, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
