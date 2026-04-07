import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/event_model.dart';
import '../../providers/theme_provider.dart';
import 'add_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabAnimation;
  
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Technical', 'Cultural', 'Sports', 'Academic', 'Workshop'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDarkMode),
          _buildCategoryFilter(isDarkMode),
          _buildEventsList(isDarkMode),
        ],
      ),
      floatingActionButton: _buildAddEventFAB(isDarkMode),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : const Color(0xFF1E293B),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Events & Notices',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode ? [
                const Color(0xFF1E293B),
                const Color(0xFF334155),
                const Color(0xFF475569),
                const Color(0xFF64748B),
              ] : [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  right: 20,
                  child: Icon(
                    Icons.event_rounded,
                    size: 120,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Icon(
                    Icons.notifications_active_outlined,
                    size: 90,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 50,
                  child: Icon(
                    Icons.celebration_outlined,
                    size: 60,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDarkMode) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode ? [
                const Color(0xFF1E293B),
                const Color(0xFF334155),
              ] : [
                const Color(0xFFFFFFFF),
                const Color(0xFFF8FAFC),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Filter events by category',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  )
                                : null,
                            color: isSelected ? null : (isDarkMode ? const Color(0xFF475569) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF667eea).withOpacity(0.4)
                                    : Colors.black.withOpacity(0.04),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 18,
                                color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : const Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : const Color(0xFF64748B)),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Technical':
        return Icons.computer;
      case 'Cultural':
        return Icons.theater_comedy;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Academic':
        return Icons.school;
      case 'Workshop':
        return Icons.build;
      default:
        return Icons.event;
    }
  }

  Widget _buildEventsList(bool isDarkMode) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .orderBy('startDate', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            print('🎉 Events Stream State: ${snapshot.connectionState}');
            print('🎉 Has Data: ${snapshot.hasData}');
            print('🎉 Docs Count: ${snapshot.data?.docs.length ?? 0}');
            print('🎉 Error: ${snapshot.error}');

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(isDarkMode);
            }

            if (snapshot.hasError) {
              print('❌ Events Error: ${snapshot.error}');
              return _buildErrorState(isDarkMode);
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              print('📭 Events: No data or empty');
              return _buildEmptyState(isDarkMode);
            }
            
            // Filter events based on category and active status
            final allEvents = snapshot.data!.docs
                .map((doc) => EventModel.fromFirestore(doc))
                .where((event) => event.isActive) // Only active events
                .toList();

            final events = _selectedCategory == 'All'
                ? allEvents
                : allEvents.where((event) => event.category == _selectedCategory).toList();

            // Check if filtered events are empty
            if (events.isEmpty) {
              return _buildEmptyState(isDarkMode);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: events.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  return _buildEventCard(event, index, isDarkMode);
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, int index, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Image with default spacing
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              width: 120,
              height: 140,
              child: CachedNetworkImage(
                imageUrl: event.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          
          // Right side - Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: const Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(event.startDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildAddEventFAB(bool isDarkMode) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventPage()),
          );
        },
        backgroundColor: isDarkMode ? const Color(0xFF475569) : const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Container(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your internet connection and try again.',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory == 'All'
                ? 'No events are currently available.'
                : 'No events found in $_selectedCategory category.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
