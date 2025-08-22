import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome_screen.dart';

// ===================================================================
// 1. WIDGET UTAMA (STATEFUL) UNTUK MENGATUR NAVIGASI
// ===================================================================
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;
  String userName = "Memuat...";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Pengguna';
      userEmail = prefs.getString('userEmail') ?? 'Tidak ada email';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      BerandaPage(userName: userName, userEmail: userEmail),
      const AkademikPage(),
      ProfilePage(userName: userName, userEmail: userEmail),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4579E3),
        unselectedItemColor: const Color(0xFFC0C5CC),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_outlined),
            label: 'Akademik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ===================================================================
// 2. TAMPILAN BERANDA (SAMA SEPERTI PUNYAMU)
// ===================================================================
class BerandaPage extends StatelessWidget {
  final String userName;
  final String userEmail;
  const BerandaPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  final List<Map<String, dynamic>> menuItems = const [
    {
      'icon': Icons.calendar_today_outlined,
      'label': 'Kaldik',
      'color': Color(0xFF5B71E1),
    },
    {
      'icon': Icons.account_balance_outlined,
      'label': 'Rektor',
      'color': Color(0xFFF16161),
    },
    {
      'icon': Icons.edit_note_outlined,
      'label': 'Nilai',
      'color': Color(0xFFFFCC33),
    },
    {
      'icon': Icons.check_circle_outline,
      'label': 'Presensi',
      'color': Color(0xFF5ED067),
    },
    {
      'icon': Icons.sticky_note_2_outlined,
      'label': 'Cat PA',
      'color': Color(0xFFB15EE6),
    },
    {
      'icon': Icons.menu_book_outlined,
      'label': 'Buku',
      'color': Color(0xFF5ECEC1),
    },
    {
      'icon': Icons.list_alt_outlined,
      'label': 'LPBA',
      'color': Color(0xFF67B0FF),
    },
    {'icon': Icons.more_horiz, 'label': 'Lainnya', 'color': Color(0xFFE58742)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Selamat datang di,',
                style: TextStyle(fontSize: 12, color: Color(0xFF909399)),
              ),
              SizedBox(height: 2),
              Text(
                'KPSP Mobile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Logo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card info user
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4579E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Text(
                              'Sistem Informasi',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ' | ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'IPK 3.8',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '63 SKS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/dashbord_img.png',
                        width: 150,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.white30,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menu grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Notifikasi card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF5ED067),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pendaftaran Program Magang Mahasiswa bersertifikat batch 2',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                    Icon(Icons.close, color: Color(0xFFB0B0B0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// 3. HALAMAN AKADEMIK
// ===================================================================
class AkademikPage extends StatelessWidget {
  const AkademikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akademik'),
        backgroundColor: const Color(0xFF4579E3),
      ),
      body: const Center(
        child: Text('Halaman Akademik', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// ===================================================================
// 4. HALAMAN PROFILE + LOGOUT
// ===================================================================
class ProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4579E3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: $userName", style: const TextStyle(fontSize: 18)),
            Text("Email: $userEmail", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
