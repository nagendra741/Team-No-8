import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Welcome to Campus Companion!',
      message: 'Explore all the amazing features available in your campus app.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.celebration_rounded,
      color: const Color(0xFF6366F1),
    ),
    NotificationItem(
      id: '2',
      title: 'New Faculty Added',
      message: 'Dr. Sarah Johnson has been added to the Computer Science department.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.person_add_rounded,
      color: const Color(0xFF8B5CF6),
    ),
    NotificationItem(
      id: '3',
      title: 'Lost Item Found',
      message: 'A blue backpack has been found near the library. Check Lost & Found.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      icon: Icons.backpack_rounded,
      color: const Color(0xFF06B6D4),
    ),
    NotificationItem(
      id: '4',
      title: 'Campus Event',
      message: 'Annual Tech Fest starts tomorrow at 9:00 AM in the main auditorium.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.event_rounded,
      color: const Color(0xFFF59E0B),
    ),
    NotificationItem(
      id: '5',
      title: 'System Update',
      message: 'The app has been updated with new features and improvements.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.system_update_rounded,
      color: const Color(0xFF10B981),
      isRead: true,
    ),
  ];

  List<NotificationItem> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  List<NotificationItem> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }
  
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
  
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
