import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpsp/screens/signin_screen.dart';
import 'package:kpsp/screens/signup_screen.dart';
import 'package:kpsp/theme/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // State untuk mengontrol tampilan layar
  bool _showMainContent = false;

  @override
  void initState() {
    super.initState();
    // Setelah 2 detik, ganti tampilan ke halaman utama WelcomeScreen
    // atau bisa juga menunggu user melakukan interaksi.
    // Timer(const Duration(seconds: 2), () {
    //   if (mounted) {
    //     setState(() {
    //       _showMainContent = true;
    //     });
    //   }
    // });
  }

  /// Mengubah state untuk menampilkan konten utama
  void _startApp() {
    setState(() {
      _showMainContent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20.0,
              ),
              child: _showMainContent ? _buildMainContent() : _buildNarrative(),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan narasi atau halaman awal
  Widget _buildNarrative() {
    return Column(
      children: [
        const Spacer(flex: 2),
        const Icon(Icons.monitor_heart, color: Colors.white, size: 80),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Pantau tumbuh kembang buah hati Anda\ndengan mudah dan akurat.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 24.0,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(flex: 1),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: _startApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: lightColorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Lanjut',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  /// Widget untuk menampilkan judul dan tombol login/signup
  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Deteksi Dini\nTumbuh Kembang Anak',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Masuk untuk melanjutkan atau daftar jika Anda pengguna baru.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 80),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _WelcomeButton(
                buttonText: 'Masuk',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (e) => const SignInScreen()),
                  );
                },
                color: Colors.white,
                textColor: lightColorScheme.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _WelcomeButton(
                buttonText: 'Daftar',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (e) => const SignUpScreen()),
                  );
                },
                color: Colors.transparent,
                textColor: Colors.white,
                borderColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.borderColor,
  });

  final String buttonText;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
