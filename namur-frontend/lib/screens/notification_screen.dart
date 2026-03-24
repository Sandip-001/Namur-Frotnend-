import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../utils/api_url.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Set<String> readNotificationIds = {};

  List<dynamic> _filterNotificationsByUser(List<dynamic> items, String userId) {
    return items.where((item) {
      if (item is! Map) return true;

      final itemUserId =
          item['user_id'] ?? item['userId'] ?? item['recipient_id'] ?? item['recipientId'];

      // If API item has no user field, keep it to avoid accidental blank state.
      if (itemUserId == null) return true;

      return itemUserId.toString() == userId;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadReadNotifications();
  }

  Future<void> _loadReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? readIds = prefs.getStringList('read_notifications');
    if (readIds != null) {
      setState(() {
        readNotificationIds = readIds.toSet();
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    if (!readNotificationIds.contains(notificationId)) {
      setState(() {
        readNotificationIds.add(notificationId);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'read_notifications',
        readNotificationIds.toList(),
      );
    }
  }

  final List<Color> bellColors = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
  ];

  Future<List<dynamic>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null || userId.trim().isEmpty) {
        print("User not logged in");
        return [];
      }

      final normalizedUserId = userId.trim();
      final url = Uri.parse(ApiConstants.notificationsByUser(normalizedUserId));
      print("📡 Fetching notifications for uid=$normalizedUserId from: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print("📊 Response Status: ${response.statusCode}");
      print("📝 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Handle different response formats
        if (decoded is List) {
          return _filterNotificationsByUser(decoded, normalizedUserId);
        } else if (decoded is Map) {
          // Try common wrapper keys
          if (decoded['data'] is List) {
            return _filterNotificationsByUser(decoded['data'], normalizedUserId);
          }
          if (decoded['notifications'] is List) {
            return _filterNotificationsByUser(decoded['notifications'], normalizedUserId);
          }
          if (decoded['items'] is List) {
            return _filterNotificationsByUser(decoded['items'], normalizedUserId);
          }
          // Return empty if no array found
          return [];
        }
        return [];
      }

      print("⚠️ User notification API returned ${response.statusCode}; showing empty list");
      return [];
    } on TimeoutException {
      print("Request timeout while fetching notifications");
      return [];
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  void _showNotificationPopup(BuildContext context, Map<String, dynamic> item) {
    if (item['id'] != null) {
      _markAsRead(item['id'].toString());
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item["title"] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            item["description"] ?? "",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  /// Convert "sent_at" → "10 min ago", "1 hour ago", "2 days ago"
  String timeAgo(String sentTime) {
    DateTime sentAt = DateTime.parse(sentTime).toLocal();
    Duration diff = DateTime.now().difference(sentAt);

    if (diff.inMinutes < 1) return "just_now".tr();
    if (diff.inMinutes < 60) {
      return "minutes_ago".tr(args: [diff.inMinutes.toString()]);
    }
    if (diff.inHours < 24) {
      return "hours_ago".tr(args: [diff.inHours.toString()]);
    }
    if (diff.inDays < 7) return "days_ago".tr(args: [diff.inDays.toString()]);

    int weeks = (diff.inDays / 7).floor();
    return "weeks_ago".tr(args: [weeks.toString()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "notifications".tr(), showBack: true),
      drawer: const DrawerMenu(),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: fetchNotifications(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return Center(child: Text("no_notifications".tr()));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final item = data[i];

              return Opacity(
                opacity:
                    (item['id'] != null &&
                        readNotificationIds.contains(item['id'].toString()))
                    ? 0.5
                    : 1.0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showNotificationPopup(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bell Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bellColors[i % bellColors.length],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // TITLE
                        Expanded(
                          child: Text(
                            item["title"] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // TIME
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            timeAgo(item["sent_at"]),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
