// screens/child_form_screen.dart
import 'package:flutter/material.dart';
import '../services/child_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';

class ChildFormScreen extends StatefulWidget {
  final Map<String, dynamic>? child;

  const ChildFormScreen({super.key, this.child});

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChildService _childService = ChildService();

  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _gestationalAgeController;
  String? _gender;
  bool _isSaving = false;
  List<String> _apiErrors = [];
  String? _birthHistory; // normal atau premature

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child?["name"] ?? "");
    _gender = widget.child?["gender"];
    _birthHistory = widget.child?["birth_history"]?.toString().toLowerCase();
    _gestationalAgeController = TextEditingController(
      text: widget.child?["gestational_age"]?.toString() ?? "",
    );

    if (widget.child != null && widget.child!["date_of_birth"] != null) {
      try {
        final dateTime = DateTime.parse(widget.child!["date_of_birth"]);
        _dateController = TextEditingController(
          text: DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime),
        );
      } catch (e) {
        _dateController = TextEditingController(
          text: widget.child!["date_of_birth"],
        );
      }
    } else {
      _dateController = TextEditingController(text: "");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _gestationalAgeController.dispose();
    super.dispose();
  }

  /// FIELD Usia Kehamilan
  Widget _buildGestationalAgeField() => TextFormField(
    controller: _gestationalAgeController,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: "Usia Kehamilan",
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.normal,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIcon: const Icon(Icons.access_time, color: Color(0xFF6F51E9)),
      suffixText: "minggu",
      suffixStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6F51E9), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return "Usia kehamilan wajib diisi";
      final n = int.tryParse(value);
      if (n == null || n < 20 || n > 45) {
        return "Masukkan angka antara 20-45 minggu";
      }
      return null;
    },
  );

  /// Dropdown Riwayat Kelahiran
  Widget _buildBirthHistoryDropdown() => DropdownButtonFormField<String>(
    value: _birthHistory,
    decoration: InputDecoration(
      labelText: "Riwayat Kelahiran",
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.normal,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIcon: const Icon(Icons.history_edu, color: Color(0xFF6F51E9)),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6F51E9), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),
    items: const [
      DropdownMenuItem(value: 'normal', child: Text('Normal')),
      DropdownMenuItem(value: 'premature', child: Text('Premature')),
    ],
    onChanged: (value) => setState(() => _birthHistory = value),
    validator: (value) => value == null ? "Pilih riwayat kelahiran" : null,
  );

  /// SIMPAN DATA ANAK
  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _apiErrors = [];
    });

    try {
      final formattedDate = _dateController.text.isNotEmpty
          ? DateFormat(
              'dd MMMM yyyy',
              'id_ID',
            ).parse(_dateController.text).toIso8601String()
          : "";

      int? gestationalAge;
      if (_gestationalAgeController.text.isNotEmpty) {
        gestationalAge = int.tryParse(_gestationalAgeController.text);
        if (gestationalAge == null) {
          throw Exception('Usia kehamilan harus berupa angka');
        }
      }

      Map<String, dynamic> response;
      if (widget.child == null) {
        response = await _childService.addChild(
          _nameController.text,
          _gender!,
          formattedDate,
          _birthHistory!,
          gestationalAge: gestationalAge,
        );
      } else {
        response = await _childService.updateChild(
          widget.child!["id"],
          _nameController.text,
          _gender!,
          formattedDate,
          _birthHistory!,
          gestationalAge: gestationalAge,
        );
      }

      if (response["success"] == true) {
        await Flushbar(
          message: widget.child == null
              ? "🎉 Berhasil mendaftarkan anak!"
              : "🎉 Data anak berhasil diperbarui!",
          backgroundColor: const Color(0xFF6F51E9),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          flushbarPosition: FlushbarPosition.TOP,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        ).show(context);
        Navigator.pop(context, true);
      } else {
        // tampilkan pesan error dari API
        if (response["errors"] != null) {
          Map errorsMap = response["errors"];
          _apiErrors = errorsMap.values
              .map((e) => e is List ? e.join(", ") : e.toString())
              .toList();
        } else if (response["message"] != null) {
          _apiErrors = [response["message"].toString()];
        } else {
          _apiErrors = [response.toString()];
        }
      }
    } catch (e) {
      _apiErrors = ["Terjadi kesalahan: $e"];
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Date Picker
  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate;

    if (_dateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).parse(_dateController.text);
      } catch (e) {
        initialDate = now;
      }
    } else {
      initialDate = now;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6F51E9),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.child != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Latar belakang gradien
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6F51E9), Color(0xFF9F7AEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.45,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(isEdit),
                  const SizedBox(height: 32),
                  if (_apiErrors.isNotEmpty) _buildErrorMessages(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: "Nama Anak",
                            icon: Icons.person_outline,
                            validator: (value) => value == null || value.isEmpty
                                ? "Nama wajib diisi"
                                : null,
                          ),
                          const SizedBox(height: 24),
                          _buildDropdown(), // Gender
                          const SizedBox(height: 24),
                          _buildBirthHistoryDropdown(), // Riwayat kelahiran
                          const SizedBox(height: 24),
                          _buildGestationalAgeField(), // Usia kehamilan
                          const SizedBox(height: 24),
                          _buildDateField(), // Tanggal lahir
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: _buildGradientButton(
                              isEdit ? "Perbarui Data" : "Simpan Data",
                              onPressed: _isSaving ? null : _saveChild,
                              isSaving: _isSaving,
                            ),
                          ),
                        ],
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

  /// Header
  Widget _buildHeader(bool isEdit) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          Column(
            children: [
              Text(
                isEdit ? "Edit Data Anak" : "Tambah Data Anak",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEdit
                    ? "Perbarui informasi anak Anda."
                    : "Silakan isi data diri anak.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pesan Error API
  Widget _buildErrorMessages() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _apiErrors
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Input Text Generic
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    style: const TextStyle(fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIcon: Icon(icon, color: const Color(0xFF6F51E9)),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6F51E9), width: 2),
      ),
    ),
    validator: validator,
  );

  /// Dropdown Gender
  Widget _buildDropdown() => DropdownButtonFormField<String>(
    value: _gender,
    items: const [
      DropdownMenuItem(value: "male", child: Text("Laki-laki")),
      DropdownMenuItem(value: "female", child: Text("Perempuan")),
    ],
    decoration: InputDecoration(
      labelText: "Jenis Kelamin",
      prefixIcon: const Icon(Icons.wc, color: Color(0xFF6F51E9)),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    onChanged: (value) => setState(() => _gender = value),
    validator: (value) => value == null ? "Pilih jenis kelamin" : null,
  );

  /// Input Date
  Widget _buildDateField() => TextFormField(
    controller: _dateController,
    readOnly: true,
    onTap: _pickDate,
    style: const TextStyle(fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: "Tanggal Lahir",
      prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF6F51E9)),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6F51E9)),
    ),
    validator: (value) =>
        value == null || value.isEmpty ? "Tanggal lahir wajib diisi" : null,
  );

  /// Tombol Gradient
  Widget _buildGradientButton(
    String text, {
    VoidCallback? onPressed,
    bool isSaving = false,
  }) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [Color(0xFF6F51E9), Color(0xFF9F7AEA)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6F51E9).withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: isSaving
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    ),
  );
}
