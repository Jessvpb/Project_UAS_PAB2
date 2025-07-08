import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:akiflash/view_models/auth_view_model.dart';
import 'package:akiflash/providers/theme_provider.dart';
import 'package:akiflash/widgets/theme_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userData = await authViewModel.getUserData();
    if (userData != null) {
      _nameController.text = userData['name'] ?? '';
      _phoneController.text = userData['phoneNumber'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authViewModel.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Error loading profile'),
            );
          }

          final userData = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF1976D2),
                flexibleSpace: FlexibleSpaceBar(
                  background: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: themeProvider.getPrimaryGradient(context),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              AnimatedBuilder(
                                animation: _slideAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _slideAnimation.value,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userData['name'] ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userData['email'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isEditing = !_isEditing);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                      child: Opacity(
                        opacity: _slideAnimation.value.clamp(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Profile Info Card
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1976D2).withOpacity(0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1976D2).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: const Icon(
                                              Icons.person_outline_rounded,
                                              color: Color(0xFF1976D2),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Personal Information',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      
                                      // Name Field
                                      _buildInputField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        icon: Icons.person_outline_rounded,
                                        enabled: _isEditing,
                                        validator: (value) {
                                          if (_isEditing && (value == null || value.isEmpty)) {
                                            return 'Name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Phone Field
                                      _buildInputField(
                                        controller: _phoneController,
                                        label: 'Phone Number',
                                        icon: Icons.phone_outlined,
                                        enabled: _isEditing,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (_isEditing && value != null) {
                                            if (value.isEmpty) return 'Phone number is required';
                                            if (!RegExp(r'^\+?1?\d{9,15}$').hasMatch(value)) {
                                              return 'Enter a valid phone number';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Email Field (Read-only)
                                      _buildInputField(
                                        initialValue: userData['email'] ?? '',
                                        label: 'Email Address',
                                        icon: Icons.email_outlined,
                                        enabled: false,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Action Buttons
                                if (_isEditing) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildActionButton(
                                          label: 'Cancel',
                                          icon: Icons.close_rounded,
                                          color: Colors.grey[600]!,
                                          backgroundColor: Colors.grey[100]!,
                                          onPressed: () {
                                            setState(() => _isEditing = false);
                                            _loadUserData();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildActionButton(
                                          label: 'Save Changes',
                                          icon: Icons.check_rounded,
                                          color: Colors.white,
                                          backgroundColor: const Color(0xFF1976D2),
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              final user = authViewModel.getCurrentUser();
                                              if (user != null) {
                                                await authViewModel.updateUserData(
                                                  name: _nameController.text,
                                                  phoneNumber: _phoneController.text,
                                                );
                                                setState(() => _isEditing = false);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Profile updated successfully'),
                                                    backgroundColor: const Color(0xFF1976D2),
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  _buildMenuItems(),
                                ],
                                
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        color: enabled ? const Color(0xFF1A1A1A) : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF1976D2) : Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled 
                ? const Color(0xFF1976D2).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF1976D2) : Colors.grey[500],
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: backgroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.history_rounded,
        'title': 'Order History',
        'subtitle': 'View your past orders',
        'onTap': () {},
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Wishlist',
        'subtitle': 'Your favorite products',
        'onTap': () {},
      },
      {
        'icon': Icons.settings_rounded,
        'title': 'Settings',
        'subtitle': 'App preferences',
        'onTap': () {},
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact us',
        'onTap': () {},
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Theme',
        'subtitle': 'Switch between light and dark mode',
        'onTap': () {},
        'trailing': const ThemeToggleButton(showLabel: false),
      },
      {
        'icon': Icons.logout_rounded,
        'title': 'Sign Out',
        'subtitle': 'Sign out from your account',
        'onTap': () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                    try {
                      await authViewModel.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pushReplacementNamed('/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Signed out successfully'),
                            backgroundColor: const Color(0xFF1976D2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Color(0xFF1976D2)),
                  ),
                ),
              ],
            ),
          );
        },
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: const Color(0xFF1976D2),
                size: 24,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: item.containsKey('trailing') ? item['trailing'] as Widget : const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF1976D2),
              size: 16,
            ),
            onTap: item['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }
}