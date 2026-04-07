import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'events/events_page.dart';
import 'lost_and_found/lost_and_found_page.dart';
import 'feedback/feedback_page.dart';
import 'gps/gps_page.dart';
import 'faculty/faculty_page.dart';
import 'settings/settings_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentImageIndex = 0;

  final List<String> _images = [
    'clg_Images/college_block.jpg',
    'clg_Images/Auditorium.jpg',
    'clg_Images/Tifac_Core_Block_And_IRC.jpg',
    'clg_Images/hostel.jpg',
    'clg_Images/BhagatsinghHostel_Road.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Start with a high initial page to allow infinite scrolling
    _pageController = PageController(initialPage: _images.length * 1000);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context, isDarkMode),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, size, isDarkMode),
            ),
            SliverToBoxAdapter(
              child: _buildFeatureSection(context, size, isDarkMode),
            ),
            SliverToBoxAdapter(
              child: _buildQuickStats(context, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Campus Companion',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1E40AF),
      surfaceTintColor: const Color(0xFF1E40AF),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1E40AF),
        statusBarIconBrightness: Brightness.light,
      ),
      actions: [
        // College Logo in AppBar
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'clg_Images/college_Logo.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 20,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        children: [
          // Elegant Drawer Header with sophisticated gradient
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4C1D95), // Deep purple
                  Color(0xFF7C3AED), // Vibrant purple
                  Color(0xFF8B5CF6), // Light purple
                  Color(0xFFA78BFA), // Lavender
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Logo Container
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'clg_Images/college_Logo.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Enhanced Text with shadow
                    Container(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Companion',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kalasalingam University',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.navigation_rounded,
                  'GPS Routing',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GPSPage())),
                  isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  Icons.people_rounded,
                  'Faculty Directory',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FacultyDirectoryPage())),
                  isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  Icons.search_rounded,
                  'Lost & Found',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LostAndFoundPage())),
                  isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  Icons.event_rounded,
                  'Events',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage())),
                  isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  Icons.feedback_rounded,
                  'Feedback',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage())),
                  isDarkMode,
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings_rounded,
                  'Settings',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
                  isDarkMode,
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  Icons.info_rounded,
                  'About',
                  () => _showAboutDialog(context),
                  isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildHeader(BuildContext context, Size size, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFFF093FB),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // College Logo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'clg_Images/college_Logo.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // College Name
                  const Expanded(
                    child: Text(
                      'Kalasalingam University',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Main Content Row
              Row(
                children: [
                  // Left side - Text Content with 5+ and 90+ stats
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campus\nCompanion',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your unified platform for campus navigation,\nfaculty directory, and campus services.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Only 5+ and 90+ stats here
                        Row(
                          children: [
                            _buildStatCard('5+', 'Features'),
                            const SizedBox(width: 12),
                            _buildStatCard('90+', 'Faculty'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right side - Infinite Auto-Scrolling Carousel
                  Expanded(
                    flex: 2,
                    child: _buildInfiniteCarousel(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 24/7 stat moved down here
              Row(
                children: [
                  _buildStatCard('24/7', 'Available'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfiniteCarousel() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            // Use modulo to create infinite loop
            final imageIndex = index % _images.length;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_images[imageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context, Size size, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Features',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover all the amazing features available',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          // Feature Grid - 2x2 Block Layout
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildFeatureCard(
                context,
                Icons.navigation_rounded,
                'GPS Routing',
                'Navigate campus with real-time directions',
                [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GPSPage())),
                isDarkMode,
              ),
              _buildFeatureCard(
                context,
                Icons.people_rounded,
                'Faculty Directory',
                'Find faculty information and contacts',
                [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FacultyDirectoryPage())),
                isDarkMode,
              ),
              _buildFeatureCard(
                context,
                Icons.search_rounded,
                'Lost & Found',
                'Report or search for lost items',
                [const Color(0xFF06B6D4), const Color(0xFF10B981)],
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LostAndFoundPage())),
                isDarkMode,
              ),
              _buildFeatureCard(
                context,
                Icons.event_rounded,
                'Events',
                'Stay updated with campus events',
                [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsPage())),
                isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Additional Features Row
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  Icons.feedback_rounded,
                  'Feedback',
                  'Share your thoughts and suggestions',
                  [const Color(0xFF10B981), const Color(0xFF059669)],
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage())),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  Icons.settings_rounded,
                  'Settings',
                  'Customize your app experience',
                  [const Color(0xFF6B7280), const Color(0xFF4B5563)],
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    List<Color> gradientColors,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAccessItem(
                Icons.phone,
                'Emergency',
                isDarkMode,
                () {},
              ),
              _buildQuickAccessItem(
                Icons.info,
                'About',
                isDarkMode,
                () => _showAboutDialog(context),
              ),
              _buildQuickAccessItem(
                Icons.help,
                'Help',
                isDarkMode,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(
    IconData icon,
    String label,
    bool isDarkMode,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E40AF),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Companion',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'clg_Images/college_Logo.png',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 32,
              ),
            );
          },
        ),
      ),
      children: [
        const Text(
          'A unified Flutter-based campus companion app for Kalasalingam University. '
          'Features include GPS routing, faculty directory, lost & found, feedback system, '
          'and event management.',
        ),
      ],
    );
  }
}
