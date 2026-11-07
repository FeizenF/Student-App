import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/student.dart';
import '../services/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_header.dart';

class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _npmController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _studyProgramController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final Student student = AppStateScope.of(context).student;
    _nameController.text = student.name;
    _npmController.text = student.npm;
    _birthPlaceController.text = student.birthPlace;
    _birthDate = student.birthDate;
    _birthDateController.text =
        student.birthDate == null ? '' : formatDate(student.birthDate);
    _gender = student.gender == 'Laki-laki' || student.gender == 'Perempuan'
        ? student.gender
        : null;
    _addressController.text = student.address;
    _studyProgramController.text = student.studyProgram;
    _facultyController.text = student.faculty;
    _emailController.text = student.email;
    _phoneController.text = student.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _npmController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _studyProgramController.dispose();
    _facultyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    DateTime initialDate = _birthDate ?? DateTime(now.year - 18, 1, 1);
    if (initialDate.isAfter(now)) {
      initialDate = DateTime(now.year - 18, 1, 1);
    }
    if (initialDate.isBefore(DateTime(1950))) {
      initialDate = DateTime(1950);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
    );

    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _birthDateController.text = formatDate(picked);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final Student student = Student(
      name: _nameController.text.trim(),
      npm: _npmController.text.trim(),
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _birthDate,
      gender: _gender ?? '',
      address: _addressController.text.trim(),
      studyProgram: _studyProgramController.text.trim(),
      faculty: _facultyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final AppState appState = AppStateScope.of(context);
    await appState.saveStudent(student);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biodata berhasil disimpan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biodata Mahasiswa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: <Widget>[
            const SectionHeader(title: 'Data Pribadi'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                spacing: 14,
                children: <Widget>[
                  _textField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Nama sesuai KTP',
                    icon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: _required('Nama lengkap'),
                  ),
                  _textField(
                    controller: _npmController,
                    label: 'NPM',
                    hint: 'Contoh: 2210512034',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'NPM wajib diisi.';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'NPM hanya boleh berisi angka.';
                      }
                      return null;
                    },
                  ),
                  _textField(
                    controller: _birthPlaceController,
                    label: 'Tempat Lahir',
                    hint: 'Contoh: Jakarta',
                    icon: Icons.location_city_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: _required('Tempat lahir'),
                  ),
                  _textField(
                    controller: _birthDateController,
                    label: 'Tanggal Lahir',
                    hint: 'Pilih tanggal',
                    icon: Icons.cake_outlined,
                    readOnly: true,
                    onTap: _pickBirthDate,
                    suffixIcon: const Icon(Icons.edit_calendar_outlined),
                    validator: (_) => _birthDate == null
                        ? 'Tanggal lahir wajib diisi.'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: Icon(Icons.wc_rounded),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (String? value) {
                      setState(() => _gender = value);
                    },
                    validator: (String? value) => value == null
                        ? 'Jenis kelamin wajib dipilih.'
                        : null,
                  ),
                  _textField(
                    controller: _addressController,
                    label: 'Alamat',
                    hint: 'Alamat lengkap (opsional)',
                    icon: Icons.home_outlined,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Data Akademik'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                spacing: 14,
                children: <Widget>[
                  _textField(
                    controller: _studyProgramController,
                    label: 'Program Studi',
                    hint: 'Contoh: Teknik Informatika',
                    icon: Icons.school_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: _required('Program studi'),
                  ),
                  _textField(
                    controller: _facultyController,
                    label: 'Fakultas',
                    hint: 'Contoh: Fakultas Ilmu Komputer',
                    icon: Icons.account_balance_outlined,
                    textCapitalization: TextCapitalization.words,
                    validator: _required('Fakultas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Kontak'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                spacing: 14,
                children: <Widget>[
                  _textField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'nama@student.ac.id',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi.';
                      }
                      final RegExp emailPattern =
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailPattern.hasMatch(value.trim())) {
                        return 'Format email tidak valid.';
                      }
                      return null;
                    },
                  ),
                  _textField(
                    controller: _phoneController,
                    label: 'Nomor HP',
                    hint: 'Contoh: 081234567890',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9+\-\s]'),
                      ),
                    ],
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor HP wajib diisi.';
                      }
                      if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value.trim())) {
                        return 'Nomor HP tidak valid.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Simpan Biodata',
              icon: Icons.save_outlined,
              onPressed: _save,
            ),
            const SizedBox(height: 10),
            Text(
              'Data disimpan di perangkat dan tetap tersedia saat aplikasi dibuka kembali.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }

  String? Function(String?) _required(String label) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$label wajib diisi.';
      }
      return null;
    };
  }
}
