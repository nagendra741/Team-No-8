import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/lost_and_found_item.dart';

class AddLostFoundPage extends StatefulWidget {
  const AddLostFoundPage({Key? key}) : super(key: key);

  @override
  State<AddLostFoundPage> createState() => _AddLostFoundPageState();
}

class _AddLostFoundPageState extends State<AddLostFoundPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _contactController = TextEditingController();
  final _finderNameController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = LostAndFoundCategories.categories.first;
  String _selectedStatus = 'lost';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _contactController.dispose();
    _finderNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Convert Google Drive URL if needed
      String imageUrl = FirebaseService.convertDriveUrl(_imageUrlController.text.trim());

      await FirebaseService.addLostAndFoundItem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        status: _selectedStatus,
        imageUrl: imageUrl,
        contactNumber: _contactController.text.trim(),
        finderName: _finderNameController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedStatus == 'lost' ? 'Lost' : 'Found'} item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text('Add ${_selectedStatus == 'lost' ? 'Lost' : 'Found'} Item'),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Selection
            Card(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Lost'),
                            value: 'lost',
                            groupValue: _selectedStatus,
                            onChanged: (value) => setState(() => _selectedStatus = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Found'),
                            value: 'found',
                            groupValue: _selectedStatus,
                            onChanged: (value) => setState(() => _selectedStatus = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Item Title',
                hintText: 'e.g., iPhone 13, Blue Backpack',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
              ),
              validator: (value) => value?.isEmpty == true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
              ),
              items: LostAndFoundCategories.categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Provide detailed description...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
              ),
              validator: (value) => value?.isEmpty == true ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16),

            // Image URL Field
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Google Drive Image Link',
                hintText: 'Paste Google Drive share link here',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                suffixIcon: const Icon(Icons.image),
              ),
              validator: (value) => value?.isEmpty == true ? 'Please provide an image link' : null,
            ),
            const SizedBox(height: 16),

            // Contact Number Field
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                hintText: '+91XXXXXXXXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                suffixIcon: const Icon(Icons.phone),
              ),
              validator: (value) => value?.isEmpty == true ? 'Please enter contact number' : null,
            ),
            const SizedBox(height: 16),

            // Finder Name Field
            TextFormField(
              controller: _finderNameController,
              decoration: InputDecoration(
                labelText: _selectedStatus == 'found' ? 'Finder Name' : 'Reporter Name',
                hintText: 'Your name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                suffixIcon: const Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty == true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),

            // Location Field
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Where was it lost/found?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                suffixIcon: const Icon(Icons.location_on),
              ),
              validator: (value) => value?.isEmpty == true ? 'Please enter location' : null,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedStatus == 'lost' ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Add ${_selectedStatus == 'lost' ? 'Lost' : 'Found'} Item',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
