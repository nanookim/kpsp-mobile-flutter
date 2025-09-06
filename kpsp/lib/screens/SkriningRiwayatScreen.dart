import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/set_pertanyaan_service.dart';
import '../services/child_service.dart';

class SkriningRiwayatScreen extends StatefulWidget {
  const SkriningRiwayatScreen({super.key});

  @override
  State<SkriningRiwayatScreen> createState() => _SkriningRiwayatScreenState();
}

class _SkriningRiwayatScreenState extends State<SkriningRiwayatScreen> {
  final _setService = SetPertanyaanService();
  final _childService = ChildService();

  List<Map<String, dynamic>> children = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadChildrenWithRiwayat();
  }

  int _hitungUmurBulan(String? dob) {
    if (dob == null || dob.isEmpty) return 0;
    try {
      final parsed = DateTime.parse(dob);
      final birth = DateTime(parsed.year, parsed.month, parsed.day);
      final today = DateTime.now();
      int months = (today.year - birth.year) * 12 + (today.month - birth.month);
      if (today.day < birth.day) months--;
      return months;
    } catch (e) {
      return 0;
    }
  }

  String _ageLabel(String? dob) {
    final months = _hitungUmurBulan(dob);
    if (months < 0) return '-';
    if (months < 12) {
      return '$months bln';
    } else {
      final years = months ~/ 12;
      return '$years th';
    }
  }

  String _formatTanggal(String? tgl) {
    if (tgl == null) return "-";
    try {
      final date = DateTime.parse(tgl);
      return DateFormat("dd MMM yyyy", "id_ID").format(date);
    } catch (e) {
      return tgl;
    }
  }

  Color _getColor(String? hasil) {
    switch (hasil) {
      case "Sesuai":
        return Colors.green;
      case "Meragukan":
        return Colors.orange;
      case "Penyimpangan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loadChildrenWithRiwayat() async {
    try {
      final kids = await _childService.fetchChildren();
      List<Map<String, dynamic>> data = [];
      for (var child in kids) {
        final riwayat = await _setService.fetchRiwayat(child['id']);
        data.add({
          "id": child['id'],
          "name": child['name'],
          "dob": child['date_of_birth'],
          "ageLabel": _ageLabel(child['date_of_birth']),
          "screenings": riwayat,
        });
      }
      if (!mounted) return;
      setState(() {
        children = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal load data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // HEADER
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
                                  Icons.assignment_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                "Riwayat Skrining",
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

          // BODY
          if (loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (children.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  "Belum ada data skrining.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final child = children[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, childWidget) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(opacity: value, child: childWidget),
                      );
                    },
                    child: _ExpandableChildCard(
                      name: child['name'],
                      ageLabel: child['ageLabel'],
                      dobFormatted: _formatTanggal(child['dob']),
                      screenings: child['screenings'],
                    ),
                  );
                }, childCount: children.length),
              ),
            ),
        ],
      ),
    );
  }
}

// ================= KARTU EXPANDABLE =================
class _ExpandableChildCard extends StatefulWidget {
  final String name;
  final String ageLabel;
  final String dobFormatted;
  final List screenings;

  const _ExpandableChildCard({
    required this.name,
    required this.ageLabel,
    required this.dobFormatted,
    required this.screenings,
  });

  @override
  State<_ExpandableChildCard> createState() => _ExpandableChildCardState();
}

class _ExpandableChildCardState extends State<_ExpandableChildCard> {
  bool expanded = false;

  Color _getColor(String? hasil) {
    switch (hasil) {
      case "Sesuai":
        return Colors.green;
      case "Meragukan":
        return Colors.orange;
      case "Penyimpangan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => expanded = !expanded),
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
                        widget.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Umur: ${widget.ageLabel}",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      Text(
                        "Tanggal lahir: ${widget.dobFormatted}",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
              ],
            ),
          ),
          if (expanded && widget.screenings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.screenings.length,
              itemBuilder: (context, i) {
                final s = widget.screenings[i];
                final color = _getColor(s['hasil_interpretasi']);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(Icons.assignment_rounded, color: color),
                    ),
                    title: Text(
                      s['hasil_interpretasi'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Skor: ${s['skor_mentah'] ?? '-'}"),
                        if (s['kesimpulan'] != null)
                          Text(
                            s['kesimpulan'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      DateFormat(
                        "dd MMM yyyy",
                        "id_ID",
                      ).format(DateTime.parse(s['tanggal_skrining'])),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
