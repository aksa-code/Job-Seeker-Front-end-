import 'package:flutter/material.dart';
import 'package:job_seeker/models/portfolio_model.dart';
import 'package:job_seeker/widgets/alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_seeker/services/url.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioModel portfolio;
  final VoidCallback? onDelete;

  const PortfolioCard({
    super.key,
    required this.portfolio,
    this.onDelete,
  });

  Future<void> _handleViewPortfolio(BuildContext context) async {
    try {
      String fullUrl = portfolio.fileUrl;
      
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
        final cleanPath = fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl;
        fullUrl = '$storageUrl/$cleanPath';
      }
      
      print('🔍 CHECK THIS: $fullUrl');
      print('🔍 Should be WITHOUT /api');
      
      final Uri url = Uri.parse(fullUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (context.mounted) {
          context.showSuccessAlert(
            'Opening portfolio...',
            title: 'Success',
          );
        }
      } else {
        if (context.mounted) {
          context.showErrorAlert(
            'Cannot open URL: $fullUrl',
            title: 'Error',
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (context.mounted) {
        context.showErrorAlert(
          'Failed to open portfolio: $e',
          title: 'Error',
        );
      }
    }
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.only(top: 32, bottom: 16),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C5C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF5C5C),
                    size: 40,
                  ),
                ),
              ),
              
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Delete Portfolio?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D3D),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Are you sure you want to delete this portfolio? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8E93A6).withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF5F6FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D3D),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          
                          if (onDelete != null) {
                            try {
                              onDelete!();
                              if (context.mounted) {
                                context.showSuccessAlert(
                                  'Portfolio deleted successfully',
                                  title: 'Success',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showErrorAlert(
                                  'Failed to delete portfolio: $e',
                                  title: 'Error',
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFFF5C5C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    String imageUrl = portfolio.fileUrl;
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
      imageUrl = '$storageUrl/$cleanPath';
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B8FFF).withOpacity(0.8),
                    const Color(0xFF4E73FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, size: 60, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            portfolio.skill,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D3D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            portfolio.description ?? "No description provided",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF8E93A6).withOpacity(0.9),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.open_in_browser_outlined,
                  label: "Show Portfolio",
                  color: const Color(0xFF4E73FF),
                  onTap: () => _handleViewPortfolio(context),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_outline,
                    label: "Delete",
                    color: const Color(0xFFFF5C5C),
                    onTap: () => _handleDelete(context),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Horizontal Layout
class PortfolioCardHorizontal extends StatelessWidget {
  final PortfolioModel portfolio;
  final VoidCallback? onDelete;

  const PortfolioCardHorizontal({
    super.key,
    required this.portfolio,
    this.onDelete,
  });

  Future<void> _handleViewPortfolio(BuildContext context) async {
    try {
      String fullUrl = portfolio.fileUrl;
      
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
        final cleanPath = fullUrl.startsWith('/') ? fullUrl.substring(1) : fullUrl;
        fullUrl = '$storageUrl/$cleanPath';
      }
      
      print('🔍 Horizontal - Full URL: $fullUrl');
      
      final Uri url = Uri.parse(fullUrl);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (context.mounted) {
          context.showSuccessAlert(
            'Opening portfolio...',
            title: 'Success',
          );
        }
      } else {
        if (context.mounted) {
          context.showErrorAlert(
            'Cannot open URL: $fullUrl',
            title: 'Error',
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (context.mounted) {
        context.showErrorAlert(
          'Failed to open portfolio: $e',
          title: 'Error',
        );
      }
    }
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.only(top: 32, bottom: 16),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C5C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF5C5C),
                    size: 40,
                  ),
                ),
              ),
              
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Delete Portfolio?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D3D),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Are you sure you want to delete this portfolio? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8E93A6).withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF5F6FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D3D),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          
                          if (onDelete != null) {
                            try {
                              onDelete!();
                              if (context.mounted) {
                                context.showSuccessAlert(
                                  'Portfolio deleted successfully',
                                  title: 'Success',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showErrorAlert(
                                  'Failed to delete portfolio: $e',
                                  title: 'Error',
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFFF5C5C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = portfolio.fileUrl;
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
      imageUrl = '$storageUrl/$cleanPath';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6B8FFF).withOpacity(0.8),
                      const Color(0xFF4E73FF),
                    ],
                  ),
                ),
                child: const Icon(Icons.image_outlined, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    portfolio.skill,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D3D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    portfolio.description ?? "No description",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF8E93A6).withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_browser_outlined, size: 20),
                color: const Color(0xFF4E73FF),
                onPressed: () => _handleViewPortfolio(context),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: const Color(0xFFFF5C5C),
                  onPressed: () => _handleDelete(context),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}