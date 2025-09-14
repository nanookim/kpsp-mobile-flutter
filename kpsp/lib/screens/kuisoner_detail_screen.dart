import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpsp/screens/hasil_skrining_screen.dart';
import '../services/set_pertanyaan_service.dart';

class KuisonerDetailScreen extends StatefulWidget {
  final int setId;
  final String title;
  final int childId;

  const KuisonerDetailScreen({
    super.key,
    required this.setId,
    required this.title,
    required this.childId,
  });

  @override
  State<KuisonerDetailScreen> createState() => _KuisonerDetailScreenState();
}

class _KuisonerDetailScreenState extends State<KuisonerDetailScreen> {
  final _service = SetPertanyaanService();
  bool isLoading = true;
  Map<String, dynamic>? setDetail;

  /// Simpan jawaban user, key = pertanyaanId, value = "ya" / "tidak"
  Map<int, String> _jawabanUser = {};

  @override
  void initState() {
    super.initState();
    _loadSetDetail();
  }

  Future<void> _loadSetDetail() async {
    try {
      final data = await _service.getSetWithQuestions(widget.setId);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          setDetail = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Future<void> _submitJawaban() async {
    // 💡 PENAMBAHAN: Validasi sebelum submit
    final totalQuestions = setDetail?['pertanyaan']?.length ?? 0;
    if (_jawabanUser.length < totalQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Harap jawab semua pertanyaan sebelum menyimpan.',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Menghentikan proses jika belum semua pertanyaan dijawab
    }

    try {
      final formattedJawaban = _jawabanUser.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final result = await _service.submitJawaban(
        widget.setId,
        widget.childId,
        formattedJawaban,
      );

      if (!mounted) return;

      final hasil = (result['data'] ?? result) as Map<String, dynamic>;

      final interpretasi =
          hasil['interpretasi'] ?? result['interpretasi'] ?? "-";
      final skor =
          hasil['skor']?.toString() ?? result['skor']?.toString() ?? "-";
      final rekomendasi = hasil['rekomendasi'] ?? result['rekomendasi'] ?? "-";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HasilSkriningScreen(
            interpretasi: interpretasi,
            skor: skor,
            rekomendasi: rekomendasi,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Gagal submit: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// HEADER
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
              title: Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
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
              ),
            ),
          ),

          /// LOADING
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          /// TIDAK ADA DATA
          else if (setDetail == null ||
              setDetail!['pertanyaan'] == null ||
              setDetail!['pertanyaan'].isEmpty)
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
                      "Belum ada pertanyaan di set ini",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          /// LIST PERTANYAAN
          else
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final pertanyaan = setDetail!['pertanyaan'][index];
                  final pertanyaanId = pertanyaan['id'] as int;

                  /// 🔥 Ambil nama file dari API dan mapping ke asset
                  final rawUrl = pertanyaan['url_ilustrasi'] as String?;
                  String? assetPath;
                  if (rawUrl != null && rawUrl.isNotEmpty) {
                    final fileName = rawUrl.split('/').last;
                    assetPath = 'assets/images/$fileName';
                    debugPrint(
                      "Pertanyaan $pertanyaanId, assetPath: $assetPath",
                    );
                  }

                  return _PertanyaanCard(
                    nomor: pertanyaan['nomor_urut'] ?? index + 1,
                    teks: pertanyaan['teks_pertanyaan'] ?? "-",
                    pertanyaanId: pertanyaanId,
                    onJawab: (id, jawaban) {
                      setState(() {
                        _jawabanUser[id] = jawaban;
                      });
                    },
                    selected: _jawabanUser[pertanyaanId],
                    assetIlustrasi: assetPath,
                  );
                }, childCount: setDetail!['pertanyaan'].length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitJawaban,
        label: Text(
          "Simpan Jawaban",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        icon: const Icon(Icons.save),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// ------------------------- PERTANYAAN CARD -------------------------
class _PertanyaanCard extends StatelessWidget {
  final int nomor;
  final String teks;
  final String? assetIlustrasi;
  final int pertanyaanId;
  final String? selected; // "ya" / "tidak"
  final Function(int, String) onJawab;

  const _PertanyaanCard({
    required this.nomor,
    this.assetIlustrasi,
    required this.teks,
    required this.pertanyaanId,
    required this.onJawab,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withOpacity(0.6)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Nomor + Teks pertanyaan
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF6A11CB),
                  child: Text(
                    "$nomor",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    teks,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (assetIlustrasi != null)
              Center(
                child: Image.asset(
                  assetIlustrasi!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            /// Pilihan Ya / Tidak
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: Text(
                    "Ya",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  selected: selected == "ya",
                  selectedColor: Colors.green,
                  onSelected: (_) => onJawab(pertanyaanId, "ya"),
                  labelStyle: TextStyle(
                    color: selected == "ya" ? Colors.white : Colors.black,
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    "Tidak",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  selected: selected == "tidak",
                  selectedColor: Colors.red,
                  onSelected: (_) => onJawab(pertanyaanId, "tidak"),
                  labelStyle: TextStyle(
                    color: selected == "tidak" ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
