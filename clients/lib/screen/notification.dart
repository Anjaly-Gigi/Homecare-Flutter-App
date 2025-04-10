import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> notifications = [];
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    final userId = supabase.auth.currentUser?.id;

    final response = await supabase
        .from('tbl_notification')
        .select()
        .eq('client_id', userId ?? '')
        .eq('reciever', 'Client') // Corrected spelling from 'reciever'
        .order('datetime', ascending: false);

    setState(() {
      notifications = response;
      isLoading = false;
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await supabase
          .from('tbl_notification')
          .update({'is_read': true})
          .eq('id', notificationId);

      // Update the local state to reflect the change
      setState(() {
        final index = notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          notifications[index]['is_read'] = true;
        }
      });
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notifications'),
        backgroundColor: const Color.fromRGBO(29, 51, 74, 1),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications found.'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final title = notif['title'] ?? 'No Title';
                    final message = notif['message'] ?? '';
                    final datetime = DateTime.parse(notif['datetime']);
                    final notificationId = notif['id'] ; // Assuming 'id' is the primary key

                    // Return a Column with ListTile and Divider (except for the last item)
                    return Column(
                      children: [
                        ListTile(
                          
                          title: Text(title,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(message),
                          trailing: Flexible(
                            flex: 1,
                            child: Text(
                              '${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${datetime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          leading: Icon(
                            notif['is_read'] == true
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: notif['is_read'] == true
                                ? Colors.grey
                                : Colors.orange,
                          ),
                          onTap: () {
                            if (!notif['is_read']) {
                              markNotificationAsRead(notificationId);
                            }
                          },
                        ),
                        if (index < notifications.length - 1) // Avoid divider after the last item
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 1,
                          ),
                      ],
                    );
                  },
                ),
    );
  }
}