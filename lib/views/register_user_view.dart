import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/register_model.dart';
import '../widgets/alert.dart';

class RegisterUserView extends StatefulWidget {
  const RegisterUserView({super.key});

  @override
  State<RegisterUserView> createState() => _RegisterUserViewState();
}

class _RegisterUserViewState extends State<RegisterUserView> {
  final formKey = GlobalKey<FormState>();
  final RegisterService registerService = RegisterService();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  String? role;
  final List<String> roleChoice = ["Society", "HRD"];
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    name.addListener(_validateForm);
    email.addListener(_validateForm);
    password.addListener(_validateForm);
  }

  @override
  void dispose() {
    name.removeListener(_validateForm);
    email.removeListener(_validateForm);
    password.removeListener(_validateForm);
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = name.text.isNotEmpty &&
          email.text.isNotEmpty &&
          password.text.isNotEmpty &&
          role != null;
    });
  }

  void _register() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      var data = {
        "name": name.text,
        "email": email.text,
        "password": password.text,
        "role": role,
      };

      RegisterModel result = await registerService.registerUser(data);

      setState(() => isLoading = false);

      if (result.status == true) {
        // Show success message
        AlertMessage().showAlert(context, result.message.toString(), true);

        // Navigate based on role after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (result.role == "Society") {
            Navigator.pushReplacementNamed(context, '/registerSociety');
          } else if (result.role == "HRD") {
            Navigator.pushReplacementNamed(context, '/registerCompany');
          }
        });

        // Clear form
        name.clear();
        email.clear();
        password.clear();
        setState(() => role = null);
      } else {
        // Show error message with formatted text
        String errorMessage = result.message.toString();
        
        // Format error message for better readability
        if (errorMessage.contains('email') && errorMessage.contains('already been taken')) {
          errorMessage = "Email sudah terdaftar, silakan gunakan email lain";
        } else if (errorMessage.contains('{') && errorMessage.contains('}')) {
          // Remove JSON formatting if exists
          errorMessage = errorMessage.replaceAll(RegExp(r'[{}[\]"]'), '');
          if (errorMessage.contains('email:')) {
            errorMessage = "Email sudah terdaftar, silakan gunakan email lain";
          }
        }
        
        AlertMessage().showAlert(context, errorMessage, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
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
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Color(0xFF5B86E5)),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/loginUser');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign up to get started with Fast Job",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 40),

              // Form Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Color(0xFF5B86E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF5B86E5), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Color(0xFF5B86E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF5B86E5), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: InputDecoration(
                          labelText: "Role",
                          prefixIcon: const Icon(Icons.work_outline,
                              color: Color(0xFF5B86E5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF5B86E5), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        items: roleChoice.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => role = value);
                          _validateForm();
                        },
                        hint: const Text("Select your role"),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: password,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF5B86E5)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF718096),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF5B86E5), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isFormValid && !isLoading) ? _register : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B86E5),
                            disabledBackgroundColor: const Color(0xFF5B86E5).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor:
                                const Color(0xFF5B86E5).withOpacity(0.3),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "REGISTER",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: (_isFormValid && !isLoading) 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.7),
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "already have an account? ",
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/loginUser');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: const Text(
                      "Login here",
                      style: TextStyle(
                        color: Color(0xFF5B86E5),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}