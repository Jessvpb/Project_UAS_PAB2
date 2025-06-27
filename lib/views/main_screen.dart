import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:akiflash/view_models/auth_view_model.dart';
import 'package:akiflash/views/home_screen.dart';
import 'package:akiflash/views/cart_screen.dart';
import 'package:akiflash/views/order_history_screen.dart';
import 'package:akiflash/views/favorite_screen.dart';
import 'package:akiflash/views/profile_screen.dart';
import 'package:akiflash/providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: themeProvider.getBackgroundColor(context),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _pages,
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.getCardColor(context),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : const Color(0xFF1976D2).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF42A5F5),
                unselectedItemColor: isDark
                    ? Colors.grey[400]
                    : Colors.grey[500],
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDark ? Colors.white : const Color(0xFF1976D2),
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                items: [
                  _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0, isDark),
                  _buildNavItem(Icons.favorite_rounded, Icons.favorite_border_rounded, 'Wishlist', 1, isDark),
                  _buildNavItem(Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Cart', 2, isDark),
                  _buildNavItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'History', 3, isDark),
                  _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 4, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
    bool isDark,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_selectedIndex == index ? 8 : 4),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? (isDark
                  ? const Color(0xFF42A5F5).withOpacity(0.2)
                  : const Color(0xFF1976D2).withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _selectedIndex == index ? activeIcon : inactiveIcon,
          size: 24,
          color: _selectedIndex == index
              ? const Color(0xFF42A5F5)
              : (isDark ? Colors.grey[400] : Colors.grey[500]),
        ),
      ),
      label: label,
    );
  }
}
