import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _organizerController = TextEditingController();
  final _contactController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _registrationLinkController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedCategory = 'Technical';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  bool _registrationRequired = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Technical', 'Cultural', 'Sports', 'Academic', 'Workshop', 'Seminar', 'Competition'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _organizerController.dispose();
    _contactController.dispose();
    _posterUrlController.dispose();
    _registrationLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('Event Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _titleController,
                  label: 'Event Title',
                  hint: 'Enter event title',
                  icon: Icons.event,
                  validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter event description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                _buildSectionTitle('Date & Time'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDateTimePicker('Start Date', _startDate, true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDateTimePicker('End Date', _endDate, false)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Location & Contact'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _venueController,
                  label: 'Venue',
                  hint: 'Enter venue location',
                  icon: Icons.location_on,
                  validator: (value) => value?.isEmpty ?? true ? 'Venue is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _organizerController,
                  label: 'Organizer',
                  hint: 'Enter organizer name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Organizer is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Info',
                  hint: 'Enter contact information',
                  icon: Icons.phone,
                  validator: (value) => value?.isEmpty ?? true ? 'Contact info is required' : null,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Additional Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _posterUrlController,
                  label: 'Poster URL',
                  hint: 'Enter image URL for event poster',
                  icon: Icons.image,
                ),
                const SizedBox(height: 16),
                _buildRegistrationToggle(),
                if (_registrationRequired) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _registrationLinkController,
                    label: 'Registration Link',
                    hint: 'Enter registration URL',
                    icon: Icons.link,
                  ),
                ],
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: const Color(0xFF1E293B),
      title: const Text(
        'Add New Event',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Category',
          prefixIcon: Icon(Icons.category, color: Color(0xFF6366F1)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime dateTime, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDateTime(isStart),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(dateTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.app_registration,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Registration Required',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Switch(
            value: _registrationRequired,
            onChanged: (value) {
              setState(() {
                _registrationRequired = value;
              });
            },
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Create Event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
      );

      if (time != null) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStart) {
            _startDate = newDateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 2));
            }
          } else {
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService.addEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        posterUrl: _posterUrlController.text.trim().isEmpty 
            ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400'
            : _posterUrlController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        venue: _venueController.text.trim(),
        organizer: _organizerController.text.trim(),
        contactInfo: _contactController.text.trim(),
        registrationRequired: _registrationRequired,
        registrationLink: _registrationRequired ? _registrationLinkController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
