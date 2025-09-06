import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/child_service.dart';
import 'kuisoner_screen.dart';
import 'package:intl/intl.dart';

class PilihAnakScreen extends StatefulWidget {
  const PilihAnakScreen({super.key});

  @override
  State<PilihAnakScreen> createState() => _PilihAnakScreenState();
}

class _PilihAnakScreenState extends State<PilihAnakScreen> {
  final _childService = ChildService();
  List<Map<String, dynamic>> anakList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
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

  Future<void> _loadChildren() async {
    try {
      final data = await _childService.fetchChildren();
      if (!mounted) return;
      setState(() {
        anakList = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal ambil data anak: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ====== HEADER dengan gradient sama ======
          SliverAppBar(
            expandedHeight: 180,
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
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          "assets/wave.png",
                          fit: BoxFit.cover,
                          height: 120,
                        ),
                      ),
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
                                  Icons.child_care_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                "Pilih Anak",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
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

          // ====== BODY ======
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (anakList.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  "Belum ada data anak",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final anak = anakList[index];
                  final name = anak['name'] ?? "Tanpa Nama";
                  final dobRaw = anak['date_of_birth'] ?? "-";
                  final dobFormatted = _formatDate(dobRaw);

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _AnakCard(
                      id: anak['id'],
                      name: name,
                      dobFormatted: dobFormatted,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KuisonerScreen(
                              childId: anak['id'], // ⬅️ tambah
                              childName: name, // ⬅️ tambah
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: anakList.length),
              ),
            ),
        ],
      ),
    );
  }
}

// ====== KARTU ANAK ======
class _AnakCard extends StatelessWidget {
  final int id;
  final String name;
  final String dobFormatted;
  final VoidCallback onTap;

  const _AnakCard({
    required this.id,
    required this.name,
    required this.dobFormatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              child: const Icon(
                Icons.child_care_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tanggal lahir: $dobFormatted",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
