import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_seeker/services/portfolio_service.dart';
import 'package:job_seeker/widgets/bottom_nav.dart';
import 'package:job_seeker/widgets/alert.dart';

class PortfolioAddView extends StatefulWidget {
  final bool hasExistingPortfolio;
  
  const PortfolioAddView({
    super.key,
    this.hasExistingPortfolio = false,
  });

  @override
  State<PortfolioAddView> createState() => _PortfolioAddViewState();
}

class _PortfolioAddViewState extends State<PortfolioAddView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController skillCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  File? selectedFile;
  Uint8List? selectedBytes;
  String? selectedName;
  bool isLoading = false;
  bool _isFormValid = false;

  final service = PortfolioService();

  @override
  void initState() {
    super.initState();
    skillCtrl.addListener(_validateForm);
    descCtrl.addListener(_validateForm);
  }

  @override
  void dispose() {
    skillCtrl.removeListener(_validateForm);
    descCtrl.removeListener(_validateForm);
    skillCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = skillCtrl.text.isNotEmpty &&
          descCtrl.text.isNotEmpty &&
          (selectedFile != null || selectedBytes != null);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        selectedName = result.files.single.name;
        if (kIsWeb) {
          selectedBytes = result.files.single.bytes;
          selectedFile = null;
        } else {
          selectedFile = File(result.files.single.path!);
          selectedBytes = null;
        }
      });
      _validateForm();
    }
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await service.addPortfolio(
        skill: skillCtrl.text,
        description: descCtrl.text,
        file: selectedFile,
        bytes: selectedBytes,
        filename: selectedName ?? 'file',
      );

      if (!mounted) return;

      context.showSuccessAlert(
        'Portfolio uploaded successfully',
        title: 'Success',
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/ViewPortfolio');
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      
      // Format error message
      String errorMessage = e.toString();
      
      if (errorMessage.contains('422') || errorMessage.contains('Upload gagal')) {
        errorMessage = 'File is too large. Maximum file size is 2 MB';
      } else if (errorMessage.contains('413') || errorMessage.contains('Payload Too Large')) {
        errorMessage = 'File is too large. Maximum file size is 2 MB';
      } else if (errorMessage.contains('format') || errorMessage.contains('extension')) {
        errorMessage = 'File format not supported. Use: pdf, doc, docx, jpg, or png';
      } else {
        errorMessage = 'Failed to upload portfolio. Make sure the file is not larger than 2 MB';
      }
      
      context.showErrorAlert(
        errorMessage,
        title: 'Oops!',
      );
    }
  }

  String _getFileIcon(String? filename) {
    if (filename == null) return '';
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'png':
        return '🖼️';
      default:
        return '📎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE8EDF5),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A1D3D)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.hasExistingPortfolio ? "Update Portfolio" : "Add Portfolio",
          style: const TextStyle(
            color: Color(0xFF1A1D3D),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
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
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4E73FF).withOpacity(0.1),
                        const Color(0xFF6B8FFF).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4E73FF).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E73FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.hasExistingPortfolio 
                              ? Icons.edit_document 
                              : Icons.folder_special_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.hasExistingPortfolio
                              ? "Update your portfolio to showcase your latest work"
                              : "Add your skills and portfolio to showcase your abilities",
                          style: const TextStyle(
                            color: Color(0xFF1A1D3D),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skill
                      const Text(
                        "Skill",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D3D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: skillCtrl,
                        decoration: InputDecoration(
                          hintText: "ex. Flutter Development, UI/UX Design",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FD),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D3D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Describe your portfolio, projects, or achievements...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FD),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // File Upload
                      const Text(
                        "Upload File",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D3D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedName != null
                                  ? const Color(0xFF4E73FF)
                                  : const Color(0xFFE8EDF5),
                              width: selectedName != null ? 2 : 1,
                            ),
                          ),
                          child: selectedName == null
                              ? Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4E73FF).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Color(0xFF4E73FF),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tap to upload file',
                                      style: TextStyle(
                                        color: Color(0xFF4E73FF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Maks 2 Mb.',
                                      style: TextStyle(
                                        color: const Color(0xFF8E93A6).withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'pdf, doc, docx, jpg, png',
                                      style: TextStyle(
                                        color: const Color(0xFF8E93A6).withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _getFileIcon(selectedName),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'File Selected',
                                            style: TextStyle(
                                              color: Color(0xFF10B981),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedName!,
                                            style: const TextStyle(
                                              color: Color(0xFF1A1D3D),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF10B981),
                                      size: 24,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isFormValid && !isLoading) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E73FF),
                      disabledBackgroundColor: const Color(0xFF4E73FF).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
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
                            widget.hasExistingPortfolio ? "UPDATE PORTFOLIO" : "SAVE PORTFOLIO",
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
      ),
      bottomNavigationBar: BottomNav(2),
    );
  }
}