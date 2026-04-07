import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';
import 'package:provider/provider.dart';
import 'routing_page.dart';
import 'faculty/faculty_page.dart';
import 'lost_and_found/lost_and_found_page.dart';
import 'feedback/feedback_page.dart';
import 'events/events_page.dart';
import '../widgets/feature_card.dart';
import '../widgets/animated_text.dart';
import '../widgets/notification_panel.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/auto_add_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late 
  late 
  late 
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardStaggerAnimation;
  late Animation<double> _backgroundAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  Timer? _autoScrollTimer;
  bool _showNotificationPanel = false;
  bool _showSettingsPanel = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _header
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _card
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _background
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Initialize PageController for image carousel
    _pageController = PageController();

    // Start auto-scroll timer
    _startAutoScroll();

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _header
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _header
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _cardStaggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _card
      curve: Curves.easeOutBack,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_background

    // Start animations
    _header
    _background
    Future.delayed(const Duration(milliseconds: 300), () {
      _card
    });
  }

  @override
  void dispose() {
    _header
    _card
    _background
    _scrollController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(theme),
      drawer: _buildModernDrawer(theme),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return 
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.isDarkMode
                      ? _buildDarkGradient()
                      : _buildLightGradient(),
                ),
                child: SafeArea(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(theme, size),
                      ),
                      SliverToBoxAdapter(
                        child: _buildFeatureSection(theme, size),
                      ),
                      SliverToBoxAdapter(
                        child: _buildQuickStats(theme),
                      ),
                      SliverToBoxAdapter(
                        child: _buildFooter(theme),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.light,
      leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      actions: [
        // College Logo
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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

        // Notification Button
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return Stack(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => _toggleNotificationPanel(notificationProvider),
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildModernDrawer(ThemeData theme) {
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
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
                        const Spacer(),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return IconButton(
                                icon: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20,
                                ),
                                onPressed: () => themeProvider.toggleTheme(),
                              );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Campus Companion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kalasalingam University',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [

                _buildDrawerItem(
                  icon: Icons.navigation_rounded,
                  title: 'GPS Routing',
                  subtitle: 'Navigate campus',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoutingPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people_rounded,
                  title: 'Faculty Directory',
                  subtitle: 'Find faculty info',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FacultyDirectoryPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.search_rounded,
                  title: 'Lost & Found',
                  subtitle: 'Report or find items',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LostAndFoundPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.feedback_rounded,
                  title: 'Feedback',
                  subtitle: 'Share suggestions',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbackPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event_rounded,
                  title: 'Events & Notices',
                  subtitle: 'Campus updates',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventsPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.pop(context);
                    _showSettingsDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Size size) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SlideTransition(
            position: _headerSlideAnimation,
            child: FadeTransition(
              opacity: _headerFadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '🎓 Kalasalingam University',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Main header section with image slider on the right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Text content
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedText(
                              text: 'Campus\nCompanion',
                              animationType: AnimationType.slideUp,
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 500),
                              style: TextStyle(
                                fontSize: size.width > 600 ? 48 : 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AnimatedText(
                              text: 'Your unified platform for campus navigation,\nfaculty directory, and campus services.',
                              animationType: AnimationType.fadeIn,
                              duration: const Duration(milliseconds: 800),
                              delay: const Duration(milliseconds: 1000),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildStatCard('5+', 'Features'),
                                _buildStatCard('90+', 'Faculty'),
                                _buildStatCard('24/7', 'Available'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right side - Enhanced Image Carousel
                      Expanded(
                        flex: 2,
                        child: _buildEnhancedImageCarousel(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeImageCarousel() {
    final images = [
      'clg_Images/college_block.jpg',
      'clg_Images/Auditorium.jpg',
      'clg_Images/Tifac_Core_Block_And_IRC.jpg',
      'clg_Images/hostel.jpg',
      'clg_Images/BhagatsinghHostel_Road.jpg',
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.asset(
                      images[index],
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.image_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedImageCarousel() {
    final images = [
      'clg_Images/college_block.jpg',
      'clg_Images/Auditorium.jpg',
      'clg_Images/Tifac_Core_Block_And_IRC.jpg',
      'clg_Images/hostel.jpg',
      'clg_Images/BhagatsinghHostel_Road.jpg',
    ];

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
          itemCount: null, // Infinite scroll
          onPageChanged: (index) {
            // Reset timer when user manually changes page
            _resetAutoScroll();
          },
          itemBuilder: (context, index) {
            final imageIndex = index % images.length;
            return Stack(
              children: [
                Image.asset(
                  images[imageIndex],
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.image_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                // Page indicators
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: List.generate(
                        images.length,
                        (dotIndex) => Container(
                          width: imageIndex == dotIndex ? 10 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: imageIndex == dotIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final currentPage = _pageController.page?.round() ?? 0;
        final nextPage = currentPage + 1;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetAutoScroll() {
    _autoScrollTimer?.cancel();
    _startAutoScroll();
  }

  Widget _buildFeatureSection(ThemeData theme, Size size) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Features',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover all the amazing features available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          
            animation: _cardStaggerAnimation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isSmallScreen = screenWidth < 600;
                  final isMobile = screenWidth < 480;

                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth - (isMobile ? 24 : 40),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : (isSmallScreen ? 16 : 20),
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: isMobile ? 6 : (isSmallScreen ? 8 : 12),
                        mainAxisSpacing: isMobile ? 6 : (isSmallScreen ? 8 : 12),
                        childAspectRatio: isMobile ? 1.3 : (isSmallScreen ? 1.2 : 0.9),
                  children: [
                    _buildAnimatedFeatureCard(
                      0,
                      Icons.navigation_rounded,
                      'GPS Routing',
                      'Navigate campus with real-time directions',
                      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoutingPage()),
                      ),
                    ),
                    _buildAnimatedFeatureCard(
                      1,
                      Icons.people_rounded,
                      'Faculty Directory',
                      'Find faculty information and contacts',
                      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FacultyDirectoryPage()),
                      ),
                    ),
                    _buildAnimatedFeatureCard(
                      2,
                      Icons.search_rounded,
                      'Lost & Found',
                      'Report or search for lost items',
                      [const Color(0xFF06B6D4), const Color(0xFF10B981)],
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LostAndFoundPage()),
                      ),
                    ),
                    _buildAnimatedFeatureCard(
                      3,
                      Icons.event_rounded,
                      'Events & Notices',
                      'Stay updated with campus events',
                      [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EventsPage()),
                      ),
                    ),
                  ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }



  Widget _buildAnimatedFeatureCard(
    int index,
    IconData icon,
    String title,
    String subtitle,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    final delay = index * 0.1;
    final animationValue = (_cardStaggerAnimation.value - delay).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(0, 50 * (1 - animationValue)),
      child: Opacity(
        opacity: animationValue,
        child: FeatureCard(
            icon: icon,
            title: title,
            subtitle: subtitle,
            gradientColors: gradientColors,
            onTap: onTap,
          ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildQuickAccessItem(Icons.emergency, 'Emergency', () {}),
              _buildQuickAccessItem(Icons.phone, 'Contact', () {}),
              _buildQuickAccessItem(Icons.info, 'Info', () {}),
              _buildQuickAccessItem(Icons.help, 'Help', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '© 2024 Kalasalingam University',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Campus Companion App v1.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _toggleNotificationPanel(NotificationProvider notificationProvider) {
    if (_showNotificationPanel) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _showNotificationPanel = false;
    } else {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 100,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: NotificationPanel(
              notificationProvider: notificationProvider,
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
      _showNotificationPanel = true;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Settings'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                  ),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_rounded),
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage notification preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to notification settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_rounded),
                  title: const Text('About'),
                  subtitle: const Text('App version and information'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
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
                color: Theme.of(context).colorScheme.primary,
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

  LinearGradient _buildLightGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          const Color(0xFF667EEA),
          const Color(0xFF764BA2),
          _backgroundAnimation.value,
        )!,
        Color.lerp(
          const Color(0xFF764BA2),
          const Color(0xFFF093FB),
          _backgroundAnimation.value,
        )!,
        Color.lerp(
          const Color(0xFFF093FB),
          const Color(0xFFF5576C),
          _backgroundAnimation.value,
        )!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  LinearGradient _buildDarkGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          const Color(0xFF2D1B69),
          const Color(0xFF11998E),
          _backgroundAnimation.value,
        )!,
        Color.lerp(
          const Color(0xFF11998E),
          const Color(0xFF38EF7D),
          _backgroundAnimation.value,
        )!,
        Color.lerp(
          const Color(0xFF38EF7D),
          const Color(0xFF667EEA),
          _backgroundAnimation.value,
        )!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
