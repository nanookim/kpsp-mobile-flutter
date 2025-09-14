import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:kpsp/screens/signin_screen.dart';
import 'package:kpsp/theme/theme.dart';
import 'package:kpsp/services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool agreePersonalData = true;
  // Password
  bool _obscurePassword = true; // 👁 state untuk show/hide password
  String _passwordStrength = ""; // 🔥 indikator strength password
  Color _strengthColor = Colors.red;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🔹 Fungsi untuk menampilkan dialog sukses dengan animasi
  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Berhasil",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Berhasil!"),
            ],
          ),
          content: const Text(
            "Registrasi akun berhasil. Silakan login dengan akun Anda.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (e) => const SignInScreen()),
                );
              },
              child: Text(
                "OK",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: lightColorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  /// 🔹 Fungsi untuk handle register
  Future<void> _handleRegister() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      final api = ApiService();
      final result = await api.register(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Registrasi gagal")),
        );
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the processing of personal data'),
        ),
      );
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// TOMBOL KEMBALI
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: GestureDetector(
                  //     onTap: () => Navigator.of(context).pop(),
                  //     child: Container(
                  //       padding: const EdgeInsets.all(10),
                  //       decoration: BoxDecoration(
                  //         color: Colors.white.withOpacity(0.2),
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       child: const Icon(
                  //         Icons.arrow_back_ios,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 50),

                  /// JUDUL DAN DESKRIPSI
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Mari Bergabung!',
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
                        Text(
                          'Buat akun Anda untuk memulai',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  /// FORM CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formSignupKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// Nama Lengkap Field
                            TextFormField(
                              controller: nameController,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Harap masukkan nama lengkap'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Nama Lengkap',
                                prefixIcon: const Icon(Icons.person_outline),
                                hintText: 'Masukkan nama lengkap',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: lightColorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),

                            /// Email Field
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan email';
                                }
                                final emailRegex = RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Harap masukkan email yang valid';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'email@example.com',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: lightColorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),

                            /// Password Field
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              obscuringCharacter: '•',
                              onChanged: (value) {
                                setState(() {
                                  if (value.isEmpty) {
                                    _passwordStrength = "";
                                  } else if (value.length < 8) {
                                    _passwordStrength = "Terlalu pendek";
                                    _strengthColor = Colors.red;
                                  } else {
                                    final strongRegex = RegExp(
                                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{12,}$',
                                    );
                                    final mediumRegex = RegExp(
                                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
                                    );

                                    if (strongRegex.hasMatch(value)) {
                                      _passwordStrength = "Kuat 💪";
                                      _strengthColor = Colors.green;
                                    } else if (mediumRegex.hasMatch(value)) {
                                      _passwordStrength = "Sedang 👍";
                                      _strengthColor = Colors.orange;
                                    } else {
                                      _passwordStrength = "Lemah 👎";
                                      _strengthColor = Colors.red;
                                    }
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan kata sandi';
                                }
                                final passwordRegex = RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
                                );
                                if (!passwordRegex.hasMatch(value)) {
                                  return 'Kata sandi minimal 8 karakter,\ntermasuk huruf besar, kecil, angka, dan simbol';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: '********',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: lightColorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            /// Indikator Kekuatan Kata Sandi
                            if (_passwordStrength.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _passwordStrength,
                                  style: GoogleFonts.montserrat(
                                    color: _strengthColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 25.0),

                            /// Persetujuan
                            Row(
                              children: [
                                Checkbox(
                                  value: agreePersonalData,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreePersonalData = value!;
                                    });
                                  },
                                  activeColor: lightColorScheme.primary,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Saya menyetujui pemrosesan data pribadi',
                                    style: TextStyle(color: Colors.black54),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25.0),

                            /// Tombol Daftar
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  backgroundColor: lightColorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Daftar',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30.0),

                            /// Divider
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: Divider(
                            //         thickness: 0.7,
                            //         color: Colors.grey.withOpacity(0.5),
                            //       ),
                            //     ),
                            //     const Padding(
                            //       padding: EdgeInsets.symmetric(horizontal: 10),
                            //       child: Text(
                            //         'atau',
                            //         style: TextStyle(color: Colors.black45),
                            //       ),
                            //     ),
                            //     Expanded(
                            //       child: Divider(
                            //         thickness: 0.7,
                            //         color: Colors.grey.withOpacity(0.5),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 30.0),

                            // /// Tombol Masuk Sosial
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //   children: [
                            //     _SocialButton(
                            //       icon: Brand(Brands.google),
                            //       onTap: () => ScaffoldMessenger.of(context)
                            //           .showSnackBar(
                            //             const SnackBar(
                            //               content: Text(
                            //                 "Google login belum tersedia",
                            //               ),
                            //             ),
                            //           ),
                            //     ),
                            //     _SocialButton(
                            //       icon: Brand(Brands.apple_logo),
                            //       onTap: () => ScaffoldMessenger.of(context)
                            //           .showSnackBar(
                            //             const SnackBar(
                            //               content: Text(
                            //                 "Apple login belum tersedia",
                            //               ),
                            //             ),
                            //           ),
                            //     ),
                            //     _SocialButton(
                            //       icon: Brand(Brands.facebook),
                            //       onTap: () => ScaffoldMessenger.of(context)
                            //           .showSnackBar(
                            //             const SnackBar(
                            //               content: Text(
                            //                 "Facebook login belum tersedia",
                            //               ),
                            //             ),
                            //           ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 25.0),

                            /// Sudah punya akun
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Sudah punya akun? ',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (e) => const SignInScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: lightColorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
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
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: icon,
        iconSize: 30,
        color: Colors.black54,
      ),
    );
  }
}
