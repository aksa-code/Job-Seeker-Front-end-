import 'package:flutter/material.dart';
import 'package:job_seeker/services/auth_service.dart';
import 'package:job_seeker/widgets/alert.dart';

class RegisterSocietyView extends StatefulWidget {
  final bool isEditMode;
  const RegisterSocietyView({super.key, this.isEditMode = false});

  @override
  State<RegisterSocietyView> createState() => _RegisterSocietyViewState();
}

class _RegisterSocietyViewState extends State<RegisterSocietyView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _authService = RegisterService();
  
  String _gender = "male";
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_validateForm);
    _emailCtrl.addListener(_validateForm);
    _addressCtrl.addListener(_validateForm);
    _phoneCtrl.addListener(_validateForm);
    _dobCtrl.addListener(_validateForm);
    _passwordCtrl.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_validateForm);
    _emailCtrl.removeListener(_validateForm);
    _addressCtrl.removeListener(_validateForm);
    _phoneCtrl.removeListener(_validateForm);
    _dobCtrl.removeListener(_validateForm);
    _passwordCtrl.removeListener(_validateForm);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameCtrl.text.isNotEmpty &&
          _addressCtrl.text.isNotEmpty &&
          _phoneCtrl.text.isNotEmpty &&
          _dobCtrl.text.isNotEmpty;
      
      // Email & password opsional untuk edit mode
      if (!widget.isEditMode) {
        _isFormValid = _isFormValid && 
            _emailCtrl.text.isNotEmpty &&
            _passwordCtrl.text.isNotEmpty;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B86E5),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A202C),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _registerSociety() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 🔥 DATA LENGKAP (termasuk email & password)
      final Map<String, dynamic> data = {
        "name": _nameCtrl.text,
        "address": _addressCtrl.text,
        "phone": _phoneCtrl.text,
        "date_of_birth": _dobCtrl.text,
        "gender": _gender,
      };

      // Tambahkan email jika diisi
      if (_emailCtrl.text.isNotEmpty) {
        data["email"] = _emailCtrl.text;
      }

      // Tambahkan password jika diisi
      if (_passwordCtrl.text.isNotEmpty) {
        data["password"] = _passwordCtrl.text;
      }

      final result = await _authService.registerSociety(data);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.status == true) {
        context.showSuccessAlert(
          result.message ?? "Berhasil simpan data Society",
          title: 'Success',
        );

        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        if (widget.isEditMode) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/loginUser');
        }
      } else {
        context.showErrorAlert(
          result.message ?? "Gagal simpan data Society",
          title: 'Oops!',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.showErrorAlert("Error: $e", title: 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.isEditMode
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF5B86E5)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Color(0xFF1A202C),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: const Text(
                "Complete Profile",
                style: TextStyle(
                  color: Color(0xFF1A202C),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileIcon(),
              const SizedBox(height: 32),
              
              // 🔥 SECTION: Account Information (Email & Password)
              _buildSectionTitle('Account Information'),
              const SizedBox(height: 8),
              Text(
                widget.isEditMode 
                    ? 'Leave blank if you don\'t want to change'
                    : 'Create your account credentials',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _emailCtrl,
                label: "Email Address",
                hint: "Enter your email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              _buildPasswordField(),
              const SizedBox(height: 24),
              
              // SECTION: Personal Information
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameCtrl,
                label: "Full Name",
                hint: "Enter your name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneCtrl,
                label: "Phone Number",
                hint: "Enter your phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dobCtrl,
                label: "Date of Birth",
                hint: "Select your date of birth",
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressCtrl,
                label: "Address",
                hint: "Enter your address",
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B86E5).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text('👤', style: TextStyle(fontSize: 45)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.5), fontSize: 14),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
                child: Icon(icon, color: const Color(0xFF5B86E5), size: 20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 NEW: Password Field with toggle visibility
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.isEditMode 
                  ? "Leave blank to keep current password"
                  : "Enter your password",
              hintStyle: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.5), fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF5B86E5), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A202C)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: _buildGenderOption("male", "Male", "👨")),
              Expanded(child: _buildGenderOption("female", "Female", "👩")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, String label, String emoji) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B86E5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1A202C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _isFormValid && !_isLoading;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canSubmit ? _registerSociety : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B86E5),
          disabledBackgroundColor: const Color(0xFF5B86E5).withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                widget.isEditMode ? "Update Profile" : "Complete Registration",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: canSubmit ? Colors.white : Colors.white.withOpacity(0.7),
                ),
              ),
      ),
    );
  }
}