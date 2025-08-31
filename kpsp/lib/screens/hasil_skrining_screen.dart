import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpsp/screens/main_menu_screen.dart';

class HasilSkriningScreen extends StatelessWidget {
  final String interpretasi;
  final String skor;
  final String rekomendasi;

  const HasilSkriningScreen({
    super.key,
    required this.interpretasi,
    required this.skor,
    required this.rekomendasi,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xFFF5F6FA),

      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  "Hasil Pemeriksaan",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Ringkasan hasil skrining anak Anda",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ResultCard(
                  title: "Interpretasi",
                  icon: Icons.insights_rounded,
                  content: interpretasi,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _ResultCard(
                  title: "Skor",
                  icon: Icons.emoji_events_rounded,
                  content: skor,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _ResultCard(
                  title: "Rekomendasi",
                  icon: Icons.lightbulb_rounded,
                  content: rekomendasi,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // FOOTER BUTTON
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF6A11CB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text("Kembali ke Beranda"),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                  (route) => false, // hapus semua halaman sebelumnya
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Card custom untuk tiap hasil
class _ResultCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _ResultCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
