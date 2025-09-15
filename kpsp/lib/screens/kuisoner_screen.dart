import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/set_pertanyaan_service.dart';
import 'kuisoner_detail_screen.dart'; // import detail screen
import 'package:intl/intl.dart';

class KuisonerScreen extends StatefulWidget {
  final int childId; // ⬅️ tambah
  final String childName; // ⬅️ tambah
  final String childDob; // ⬅️ tambahin
  const KuisonerScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.childDob, // ⬅️ tambahin
  });

  @override
  State<KuisonerScreen> createState() => _KuisonerScreenState();
}

class _KuisonerScreenState extends State<KuisonerScreen> {
  final _service = SetPertanyaanService();
  String? nextAvailableMessage;
  List<Map<String, dynamic>> sets = [];
  bool isLoading = true;
  final List<IconData> icons = [
    Icons.cake_rounded,
    Icons.child_friendly_rounded,
    Icons.toys_rounded,
    Icons.menu_book_rounded,
    Icons.extension_rounded,
    Icons.baby_changing_station_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return dateString;
    }
  }

  int _hitungUmurBulan(String dob) {
    try {
      final lahir = DateTime.parse(dob);
      final now = DateTime.now();

      int tahun = now.year - lahir.year;
      int bulan = now.month - lahir.month;
      int hari = now.day - lahir.day;

      if (bulan < 0 || (bulan == 0 && hari < 0)) {
        tahun--;
        bulan += 12;
      }

      return tahun * 12 + bulan;
    } catch (e) {
      return 0;
    }
  }

  int _hitungHariMenuju(String dob, int targetBulan) {
    final lahir = DateTime.parse(dob);
    final targetDate = DateTime(
      lahir.year,
      lahir.month + targetBulan,
      lahir.day,
    );
    final now = DateTime.now();

    return targetDate.difference(now).inDays;
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final data = await _service.fetchSets(widget.childId);
      final umurBulan = _hitungUmurBulan(widget.childDob);

      // debug
      debugPrint('Umur anak (bulan): $umurBulan');
      debugPrint('Data: $data');

      // Helper cek skrining sudah diisi atau belum
      bool _isNotFilled(dynamic skr) {
        if (skr == null) return true;
        final s = skr.toString().trim().toLowerCase();
        return s.isEmpty || s == 'null';
      }

      // Ambil semua set yg umurnya sudah terlewati & belum diisi
      List<Map<String, dynamic>> availableSets = data.where((set) {
        final usia = (set['usia_dalam_bulan'] as num).toInt();
        return usia <= umurBulan && _isNotFilled(set['skrining_terakhir']);
      }).toList();

      // Urutkan biar rapi
      availableSets.sort(
        (a, b) => (a['usia_dalam_bulan'] as int).compareTo(
          b['usia_dalam_bulan'] as int,
        ),
      );

      // Cari target usia berikutnya (> umur anak)
      final usiaList =
          data.map<int>((s) => (s['usia_dalam_bulan'] as num).toInt()).toList()
            ..sort();
      final nextUsia = usiaList.firstWhere(
        (u) => u > umurBulan,
        orElse: () => -1,
      );

      if (nextUsia != -1) {
        final sisaHari = _hitungHariMenuju(widget.childDob, nextUsia);
        nextAvailableMessage =
            "Kuesioner usia $nextUsia bulan bisa diisi dalam ${sisaHari > 0 ? sisaHari : 0} hari lagi";
      } else {
        nextAvailableMessage = null;
      }

      if (mounted) {
        setState(() {
          sets = availableSets;
          isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint("Error loadData: $e\n$st");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
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
                child: Stack(
                  children: [
                    Positioned(
                      bottom: -40,
                      left: 0,
                      right: 0,
                      child: Opacity(opacity: 0.2),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 30),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white24,
                                child: const Icon(
                                  Icons.assignment_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kuisoner",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.childName, // tampilkan nama anak
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),

                                  Text(
                                    "${sets.length} Set tersedia",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sets.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      size: 90,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nextAvailableMessage ?? "Belum ada data set pertanyaan",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (nextAvailableMessage == null) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Muat Ulang"),
                        onPressed: _loadData,
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final set = sets[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _SetCardPro(
                      usia: set['usia_dalam_bulan'],
                      deskripsi: set['deskripsi'] ?? "-",
                      icon: icons[index % icons.length],
                      onTap: () {
                        // buka detail screen dengan Hero
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KuisonerDetailScreen(
                              setId: set['id'],
                              title: "Usia ${set['usia_dalam_bulan']} bln",
                              childId: widget.childId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: sets.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetCardPro extends StatelessWidget {
  final int usia;
  final String deskripsi;
  final IconData icon;
  final VoidCallback onTap;

  const _SetCardPro({
    required this.usia,
    required this.deskripsi,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple.shade700, Colors.indigo.shade700]
                : [Colors.white, Colors.grey.shade100],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "usia_$usia",
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Usia $usia bln",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                deskripsi,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
