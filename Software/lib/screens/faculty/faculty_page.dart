import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_cursor.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_cursor.dart';

class FacultyDirectoryPage extends StatefulWidget {
  const FacultyDirectoryPage({super.key});

  @override
  State<FacultyDirectoryPage> createState() => _FacultyDirectoryPageState();
}

class _FacultyDirectoryPageState extends State<FacultyDirectoryPage> 
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> facultyList = [
    {"name": "Dr. P. Deepalakshmi", "designation": "Professor & Dean", "room": "8512"},
    {"name": "Dr. N. Suresh Kumar", "designation": "Professor & HoD", "room": "8612"},
    {"name": "Dr. R. Ramalakshmi", "designation": "Professor & Director", "room": "IRC First Floor"},
    {"name": "Dr. K. Kartheeban", "designation": "Associate Professor & Associate HoD", "room": "8407"},
    {"name": "Dr. R. Murugeswari", "designation": "Associate Professor", "room": "84A04"},
    {"name": "Dr. N. C. Brintha", "designation": "Associate Professor & Associate HoD", "room": "84A02"},
    {"name": "Dr. Jane Rubel Angelina", "designation": "Associate Professor", "room": "84A05"},
    {"name": "Dr. C. Bala Subramanian", "designation": "Associate Professor", "room": "84A06"},
    {"name": "Dr. M. Jayalakshmi", "designation": "Associate Professor & Associate HoD", "room": "8002"},
    {"name": "Dr. K. Maharajan", "designation": "Associate Professor & Associate HoD", "room": "84A10"},
    {"name": "Dr. A. Parivazhagan", "designation": "Associate Professor", "room": "86A09"},
    {"name": "Dr. K. S. Kannan", "designation": "Associate Professor", "room": "86A10"},
    {"name": "Dr. J. Jeya Bharathi", "designation": "Associate Professor", "room": "86A04"},
    {"name": "Dr. Abhishek Tripathi", "designation": "Associate Professor", "room": "83A13"},
    {"name": "Dr. S. Nithyanantham", "designation": "Associate Professor", "room": ""},
    {"name": "Dr. T. Dhiliphan Raikumar", "designation": "Associate Professor & Associate HoD", "room": "8602"},
    {"name": "Dr. R. Sumathi", "designation": "Associate Professor", "room": "84A3"},
    {"name": "Dr. M. Raja", "designation": "Associate Professor", "room": "83A11"},
    {"name": "Dr. P. Nagaraj", "designation": "Associate Professor", "room": "8002"},
    {"name": "Dr. P. Velumurugadass", "designation": "Associate Professor", "room": "86A08"},
    {"name": "Dr. N. Subbulakshmi", "designation": "Associate Professor", "room": "84A07"},
    {"name": "Dr. S. Ariffa Begum", "designation": "Associate Professor", "room": "84A06"},
    {"name": "Dr. V. Sathya Narayanan", "designation": "Associate Professor", "room": "84A13"},
    {"name": "Dr. J. Bharath Singh", "designation": "Associate Professor", "room": "85A08"},
    {"name": "Dr. T. Manikumar", "designation": "Associate Professor", "room": "84A08"},
    {"name": "Dr. G. Nagarajan", "designation": "Associate Professor", "room": "84A09"},
    {"name": "Dr. M. Vijay", "designation": "Associate Professor", "room": "8611"},
    {"name": "Dr. N. V. S. Natteshan", "designation": "Associate Professor", "room": "86A13"},
    {"name": "Dr. R. Raja Subramanian", "designation": "Associate Professor & Associate HoD", "room": "84A11"},
    {"name": "Dr. P. Anitha", "designation": "Associate Professor", "room": "8611"},
    {"name": "Dr. M. K. Nagarajan", "designation": "Associate Professor", "room": "83A12"},
    {"name": "Dr. P. Chinnasamy", "designation": "Associate Professor", "room": "83A01"},
    {"name": "Mr. D. Balakrishnan", "designation": "Assistant Professor", "room": "83A09"},
    {"name": "Mr. R. Raja Sekar", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Mr. S. Suresh Kumar", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Mrs. S. Shanmugapriya", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Ms. K. Bavani", "designation": "Assistant Professor", "room": "85A06"},
    {"name": "Mrs. A. M. Gurusigaamani", "designation": "Assistant Professor", "room": "83A02"},
    {"name": "Ms. V. S. Vetri Selvi", "designation": "Assistant Professor", "room": "8002"},
    {"name": "Mrs. N. Kirthiga", "designation": "Assistant Professor", "room": "8002"},
    {"name": "Mr. R. Mari Selvan", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Mr. C. Sivamurugan", "designation": "Assistant Professor", "room": "83A08"},
    {"name": "Mr. V. Manikandan", "designation": "Assistant Professor", "room": "83A14"},
    {"name": "Mrs. Loyola Jasmine", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Mr. G. Vimal Subramanian", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Mr. M. Sankara Mahalingam", "designation": "Assistant Professor", "room": "86A12"},
    {"name": "Mrs. S. Amutha", "designation": "Assistant Professor", "room": "85A02"},
    {"name": "Mrs. P. Kalaiarasi", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Mrs. R. Syed Alifathima", "designation": "Assistant Professor", "room": "85A04"},
    {"name": "Mr. D. Surendiran Muthukumar", "designation": "Assistant Professor", "room": "85A10"},
    {"name": "Ms. M. Chitra Devi", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Dr. S. Shargunam", "designation": "Assistant Professor", "room": "86A14"},
    {"name": "Mrs. P. Kardeepa", "designation": "Assistant Professor", "room": "83A03"},
    {"name": "Mr. N. R. Sathis Kumar", "designation": "Assistant Professor", "room": "85A09"},
    {"name": "Ms. T. Akilandeswari", "designation": "Assistant Professor", "room": "85A05"},
    {"name": "Mrs. S. Suitha", "designation": "Assistant Professor", "room": "85A03"},
    {"name": "Dr. T. Marmuthu", "designation": "Assistant Professor", "room": "84A01"},
    {"name": "Mr. V. Aravindarajan", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Mr. P. Suresh Babu", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Mr. R. Kalaichelvan", "designation": "Assistant Professor", "room": "8002"},
    {"name": "Mr. V. Maruthupandi", "designation": "Assistant Professor", "room": "5th Block First floor"},
    {"name": "Mr. D. Gnana Kumar", "designation": "Assistant Professor", "room": "5th Block First floor"},
    {"name": "Mr. M. Vigneshkumar", "designation": "Assistant Professor", "room": "86A11"},
    {"name": "Ms. V. Ragavarthini", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Ms. M. M. Sangeetha", "designation": "Assistant Professor", "room": "86A05"},
    {"name": "Mrs. J. Bentta", "designation": "Assistant Professor", "room": "85A07"},
    {"name": "Dr. P. Pandi Selvam", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Mr. M. Jafar Sathick Ali", "designation": "Assistant Professor", "room": "85A13"},
    {"name": "Dr. N. Sundareswaran", "designation": "Assistant Professor", "room": "8611"},
    {"name": "Mr. B. Shanmuga Raja", "designation": "Assistant Professor", "room": "85A11"},
    {"name": "Mr. Aravind Chandran", "designation": "Assistant Professor", "room": "85A14"},
    {"name": "Dr. K. Vivekrabinson", "designation": "Assistant Professor", "room": "85A12"},
    {"name": "Mrs. R. Durga Meena", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Mrs. S. Reshni", "designation": "Assistant Professor", "room": "85A01"},
    {"name": "Mr. K. Venkatesh", "designation": "Assistant Professor", "room": "84A14"},
    {"name": "Mr. Akbar Babhusha Mohideen", "designation": "Assistant Professor", "room": "84A12"},
    {"name": "Mrs. B. Lavanya", "designation": "Assistant Professor", "room": "83A06"},
    {"name": "Mr. M. Rajasekaran", "designation": "Assistant Professor", "room": "86A02"},
    {"name": "Ms. M. R. Vishnu Priya", "designation": "Assistant Professor", "room": "8602"},
    {"name": "Ms. P. J. Kiruthiga", "designation": "Assistant Professor", "room": "8602"},
  ];

  List<Map<String, String>> filteredList = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    filteredList = facultyList;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void filterSearchResults(String query) {
    List<Map<String, String>> searchResults = facultyList.where((faculty) {
      return faculty["name"]!.toLowerCase().contains(query.toLowerCase()) ||
          faculty["designation"]!.toLowerCase().contains(query.toLowerCase()) ||
          faculty["room"]!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredList = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          extendBodyBehindAppBar: true,
          appBar: _buildModernAppBar(theme),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2D1B69),
                        Color(0xFF11998E),
                        Color(0xFF38EF7D),
                      ],
                    )
                  : const LinearGradient(
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildPageHeader(),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildEnhancedFacultyCard(index),
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
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.light,
      leading: CustomCursor(
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Faculty Directory',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faculty Directory',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find faculty members by name, designation, or room',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: filterSearchResults,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: "Search faculty by name, designation, or room...",
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFacultyCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle faculty card tap
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filteredList[index]["name"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            filteredList[index]["designation"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.room_rounded,
                              size: 18,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Room ${filteredList[index]["room"]}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}