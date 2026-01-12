import 'package:flutter/material.dart';
import 'package:job_seeker/services/auth_service.dart';
import 'package:job_seeker/models/company_model.dart';
import 'package:job_seeker/widgets/alert.dart';

class RegisterCompanyView extends StatefulWidget {
  final bool isEditMode;

  const RegisterCompanyView({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<RegisterCompanyView> createState() => _RegisterCompanyViewState();
}

class _RegisterCompanyViewState extends State<RegisterCompanyView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController companyName = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController description = TextEditingController();
  bool isLoading = false;
  bool _isFormValid = false;
  bool _obscurePassword = true;

  final RegisterService _service = RegisterService();

  @override
  void initState() {
    super.initState();

    // Listen for changes in form fields
    name.addListener(_validateForm);
    email.addListener(_validateForm);
    password.addListener(_validateForm);
    companyName.addListener(_validateForm);
    address.addListener(_validateForm);
    phone.addListener(_validateForm);
    description.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Clean up the controllers
    name.removeListener(_validateForm);
    email.removeListener(_validateForm);
    password.removeListener(_validateForm);
    companyName.removeListener(_validateForm);
    address.removeListener(_validateForm);
    phone.removeListener(_validateForm);
    description.removeListener(_validateForm);
    name.dispose();
    email.dispose();
    password.dispose();
    companyName.dispose();
    address.dispose();
    phone.dispose();
    description.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Check if all required fields are filled
      _isFormValid = companyName.text.isNotEmpty &&
          address.text.isNotEmpty &&
          phone.text.isNotEmpty &&
          description.text.isNotEmpty;

      // In edit mode, name and email are required but password is optional
      if (widget.isEditMode) {
        _isFormValid = _isFormValid &&
            name.text.isNotEmpty &&
            email.text.isNotEmpty;
      } else {
        // In register mode, all fields including password are required
        _isFormValid = _isFormValid &&
            name.text.isNotEmpty &&
            email.text.isNotEmpty &&
            password.text.isNotEmpty;
      }
    });
  }

  Future<void> _saveCompany() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final Map<String, dynamic> data = {
      "name": name.text,
      "email": email.text,
      "phone": phone.text,
      "company_name": companyName.text,
      "address": address.text,
      "description": description.text,
    };

    // Only include password if it's not empty
    if (password.text.isNotEmpty) {
      data["password"] = password.text;
    }

    print('DEBUG: Sending data = $data');
    print('DEBUG: isEditMode = ${widget.isEditMode}');

    try {
      // Gunakan endpoint yang sama untuk register dan update
      final result = await _service.registerCompany(data);

      if (!mounted) return;
      setState(() => isLoading = false);

      final bool isSuccess = result.status ?? false;

      if (isSuccess) {
        if (mounted) {
          context.showSuccessAlert(
            widget.isEditMode
                ? "Company profile updated successfully"
                : "Company registered successfully",
            title: 'Success',
          );
        }

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        if (widget.isEditMode) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, '/loginUser');
        }
      } else {
        if (mounted) {
          context.showErrorAlert(
            result.message ?? "Failed to save company data",
            title: 'Oops!',
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);

      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      if (mounted) {
        context.showErrorAlert(errorMessage, title: 'Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: widget.isEditMode
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF2D3748)),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          widget.isEditMode ? "Edit Company Profile" : "Complete Company Data",
          style: const TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Account Information", "Your account credentials", Icons.account_circle),
                const SizedBox(height: 16),
                _buildTextField("Human Resource", name, "e.g. John Doe", Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField("Email Address", email, "e.g. company@example.com", Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(
                  widget.isEditMode ? "Password (Optional)" : "Password",
                  password,
                  widget.isEditMode ? "Leave blank to keep current password" : "Enter your password",
                  Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader("Company Details", "Enter your company details", Icons.business),
                const SizedBox(height: 16),
                _buildTextField("Company Name", companyName, "e.g. Tech Solutions Inc.", Icons.business_outlined),
                const SizedBox(height: 16),
                _buildTextField("Address", address, "Enter company address", Icons.location_on_outlined, maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField("Phone Number", phone, "e.g. 0812 3456 7890", Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField("Company Description", description, "Describe your company", Icons.description_outlined, maxLines: 5),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isFormValid && !isLoading) ? _saveCompany : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B86E5),
                      disabledBackgroundColor: const Color(0xFF5B86E5).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.isEditMode ? "UPDATE PROFILE" : "SAVE & CONTINUE",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5B86E5).withOpacity(0.1),
            const Color(0xFF36D1DC).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5B86E5).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF5B86E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData? icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: obscureText ? 1 : maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText && _obscurePassword,
          validator: (value) {
            // Skip validation for password in edit mode if empty
            if (widget.isEditMode && controller == password && (value == null || value.isEmpty)) {
              return null;
            }
            
            // Required field validation
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            
            // Email validation
            if (controller == email && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            
            // Password length validation (only for non-empty passwords)
            if (controller == password && value.isNotEmpty && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF5B86E5), size: 20) : null,
            suffixIcon: obscureText
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B86E5), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}