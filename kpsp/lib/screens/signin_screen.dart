import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:kpsp/screens/main_menu_screen.dart';
import 'package:kpsp/screens/signup_screen.dart';
import 'package:kpsp/theme/theme.dart';
import 'package:kpsp/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  final bool hideBackButton;
  const SignInScreen({super.key, this.hideBackButton = false});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberPassword = true;
  bool _loading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  /// 🔹 Ambil data login tersimpan
  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('savedEmail') ?? '';
      passwordController.text = prefs.getString('savedPassword') ?? '';
      rememberPassword =
          (prefs.getString('savedEmail') != null &&
          prefs.getString('savedPassword') != null);
    });
  }

  /// 🔹 Handle Login
  Future<void> _handleLogin() async {
    if (!_formSignInKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final api = AuthService();

    try {
      final result = await api.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      setState(() => _loading = false);

      if (result['success'] == true) {
        // Remember me
        final prefs = await SharedPreferences.getInstance();
        if (rememberPassword) {
          await prefs.setString('savedEmail', emailController.text.trim());
          await prefs.setString('savedPassword', passwordController.text);
        } else {
          await prefs.remove('savedEmail');
          await prefs.remove('savedPassword');
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const MainMenuScreen(showLoginSuccess: true),
            ),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Login gagal, coba lagi."),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                  // if (!widget.hideBackButton)
                  //   // Align(
                  //   //   alignment: Alignment.topLeft,
                  //   //   child: GestureDetector(
                  //   //     onTap: () => Navigator.of(context).pop(),
                  //   //     child: Container(
                  //   //       padding: const EdgeInsets.all(10),
                  //   //       decoration: BoxDecoration(
                  //   //         color: Colors.white.withOpacity(0.2),
                  //   //         borderRadius: BorderRadius.circular(10),
                  //   //       ),
                  //   //       child: const Icon(
                  //   //         Icons.arrow_back_ios,
                  //   //         color: Colors.white,
                  //   //       ),
                  //   //     ),
                  //   //   ),
                  //   // ),
                  //   const SizedBox(height: 50),

                  /// JUDUL DAN DESKRIPSI
                  Text(
                    'Selamat Datang!',
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
                    'Silakan masuk untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white70,
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
                        key: _formSignInKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                              obscureText: !_isPasswordVisible,
                              obscuringCharacter: '•',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap masukkan kata sandi';
                                }
                                if (value.length < 8) {
                                  return 'Kata sandi minimal 8 karakter';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
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
                              ),
                            ),
                            const SizedBox(height: 25.0),

                            /// Remember Me & Forget Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberPassword,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          rememberPassword = value ?? false;
                                        });
                                      },
                                      activeColor: lightColorScheme.primary,
                                    ),
                                    const Text(
                                      'Ingat Saya',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Fitur belum tersedia"),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Lupa Kata Sandi?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: lightColorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30.0),

                            /// Sign In Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _handleLogin,
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
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Masuk',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 25.0),

                            /// Divider
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
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

                            // const SizedBox(height: 25.0),

                            // /// Social login buttons (dummy)
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

                            /// Don't have an account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Belum punya akun? ',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (e) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Daftar Sekarang',
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
