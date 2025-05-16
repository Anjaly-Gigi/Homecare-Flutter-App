import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:serviceprovider/main.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:intl/intl.dart';

class RequestView extends StatefulWidget {
  const RequestView({super.key});

  @override
  _RequestViewState createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView>
    with SingleTickerProviderStateMixin {
  String? serviceProviderId;
  List<Map<String, dynamic>> bookings = [];
  late TabController _tabController;
  late Map<String, dynamic> _serviceAccountConfig;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadServiceAccountConfig();
    fetchLoggedInServiceProviderId();
    _setupFCMTokenHandling();
    _initializeFCM();
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy HH:mm a').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _initializeFCM() async {
    await _firebaseMessaging.requestPermission();
    await _refreshFCMToken();
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _refreshFCMToken(newToken: newToken);
    });
  }

  Future<void> _refreshFCMToken({String? newToken}) async {
    try {
      final token = newToken ?? await _firebaseMessaging.getToken();
      if (token == null) return;
      await supabase.from('tbl_sp').update({'fcm_token': token}).eq('id', serviceProviderId!);
      print('FCM Token Updated: $token');
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  void _setupFCMTokenHandling() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _storeFCMToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Token Refreshed: $newToken");
      await _storeFCMToken(newToken);
    });
  }

  Future<void> _storeFCMToken(String token) async {
    if (serviceProviderId == null) {
      print("Cannot store FCM token - serviceProviderId is null");
      return;
    }
    try {
      await supabase.from('tbl_sp').update({'fcm_token': token}).eq('id', serviceProviderId!);
      print("FCM token stored successfully");
    } catch (e) {
      print("Error storing FCM token: $e");
    }
  }

  void fetchFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("Initial FCM Token: $token");
      storeFCMToken(token);
    } else {
      print("Failed to retrieve FCM token");
    }
  }

  void storeFCMToken(String token) async {
    final userId = supabase.auth.currentUser?.id ?? "USER_ID"; // Use current user ID
    await supabase.from('tbl_sp').update({'fcm_token': token}).eq('id', userId);
  }

  Future<void> _loadServiceAccountConfig() async {
    _serviceAccountConfig = await loadConfig();
  }

  Future<Map<String, dynamic>> loadConfig() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/config.json');
      print("Config Loaded: $jsonString");
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print("Error loading config.json: $e");
      return {};
    }
  }

  Future<void> fetchData() async {
    if (serviceProviderId == null) return;
    try {
      final response = await supabase
          .from('tbl_request')
          .select('id, description, date, status, starttime, endtime, charge, sp_id, tbl_client (client_name, id, fcm_token)')
          .eq('sp_id', serviceProviderId!);

      setState(() {
        bookings = response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<String> getAccessToken() async {
    const List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountConfig),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountConfig),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendPushNotification(
      String? userToken, String title, String body, Map<String, dynamic>? booking) async {
    if (userToken == null) {
      print("No FCM token found for client");
      return;
    }

    try {
      final String serverKey = await getAccessToken();
      const String projectId = 'homecare-9aa6a';
      final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': userToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'current_user_fcm_token': userToken,
          },
        }
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
        // Insert into tbl_notification
        if (booking != null && booking['tbl_client'] != null) {
          await supabase.from('tbl_notification').insert({
            'client_id': booking['tbl_client']['id'], // Use client_id from tbl_client
            'sp_id': supabase.auth.currentUser?.id,
            'title': title, // Use the notification title
            'message': body, // Use the notification body
            'datetime': DateTime.now().toIso8601String(),
            'reciever': 'Client', // Corrected spelling from 'reciever'
            'is_read': false,
          }).then((value) {
            print('Notification inserted successfully: $value');
          }).catchError((error) {
            print('Error inserting notification: $error');
          });
        } else {
          print("Booking or client data is null, skipping notification insert");
        }
      } else {
        print('Failed to send FCM message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Failed Notification: $e");
    }
  }

  Future<void> fetchLoggedInServiceProviderId() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        serviceProviderId = user.id;
      });
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FAFC),
      appBar: AppBar(
         flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 29, 51, 74),
                Color.fromARGB(255, 185, 178, 200),
                 Color.fromARGB(255, 225, 217, 243)
               
                
              ],
            ),
          ),
        ),
        foregroundColor: const Color.fromARGB(255, 1, 1, 1),
      
        title: const Text('Job Requests'
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Requests'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(0),
          _buildBookingList(1),
          _buildBookingList(2),
          _buildBookingList(6),
        ],
      ),
    );
  }

  Widget _buildBookingList(int status) {
    List<int> statuses;
    if (status == 1) {
      statuses = [1, 3];
    } else if (status == 6) {
      statuses = [4, 5];
    } else {
      statuses = [status];
    }

    final filteredBookings = bookings.where((b) => statuses.contains(b['status'])).toList();

    return filteredBookings.isEmpty
        ? const Center(child: Text('No bookings found'))
        : ListView.builder(
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(filteredBookings[index]);
            },
          );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(12),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${booking['tbl_client']?['client_name'] ?? 'Unknown'}'),
            Text('Job: ${booking['description'] ?? 'N/A'}'),
            Text(
              booking['date'] != null
                  ? 'Date: ${DateFormat('dd/MM/yy').format(DateTime.parse(booking['date']))}\nTime: ${DateFormat('HH:mm').format(DateTime.parse(booking['date']))}'
                  : 'Date: N/A\nTime: N/A',
              textAlign: TextAlign.start,
            ),
            if (booking['status'] >= 3)
              Text('Start Time: ${_formatDateTime(booking['starttime'])}'),
            if (booking['status'] >= 4)
              Text('End Time: ${_formatDateTime(booking['endtime'])}'),
            if (booking['status'] >= 4)
              Text('Charge: \$${booking['charge'] != null ? booking['charge'].toString() : 'N/A'}'),
            const SizedBox(height: 10),
            _buildActionButtons(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    switch (booking['status']) {
      case 0:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _updateStatus(booking['id'], 1, 'Request Accepted', 'Your booking has been accepted.', booking),
              child: const Text('Accept'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => _updateStatus(booking['id'], 2, 'Request Rejected', 'Your booking has been rejected.', booking),
              child: const Text('Reject'),
            ),
          ],
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => _startJob(booking['id']),
              child: const Text('Start Job'),
            ),
          ],
        );
      case 3:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => _showEndJobDialog(booking['id']),
              child: const Text('End Job'),
            ),
          ],
        );
      case 5:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  void _showEndJobDialog(int bookingId) {
    TextEditingController chargeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Job'),
          content: TextField(
            controller: chargeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter Job Amount'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                double charge = double.tryParse(chargeController.text) ?? 0.0;
                _endJob(bookingId, charge);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateStatus(int bookingId, int status, String title, String body, Map<String, dynamic> booking) async {
    if (status == 1) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final now = DateTime.now();
        final selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        final formattedTime = DateFormat('hh:mm a').format(selectedDateTime);

        title = "Service Provider Accepted the Job";
        body = "The service provider will reach you by $formattedTime.";

        await supabase.from('tbl_request').update({
          'status': status,
        }).match({'id': bookingId});

        if (booking['tbl_client'] != null && booking['tbl_client']['fcm_token'] != null) {
          await sendPushNotification(booking['tbl_client']['fcm_token'], title, body, booking);
        } else {
          print("FCM token is null. Notification not sent.");
        }

        fetchData();
      } else {
        print("Time selection canceled");
        return;
      }
    } else {
      await supabase.from('tbl_request').update({'status': status}).match({'id': bookingId});

      if (booking['tbl_client'] != null && booking['tbl_client']['fcm_token'] != null) {
        await sendPushNotification(booking['tbl_client']['fcm_token'], title, body, booking);
      } else {
        print("FCM token is null. Notification not sent.");
      }

      fetchData();
    }
  }

  void _startJob(int bookingId) async {
    String startTime = DateTime.now().toIso8601String();
    await supabase.from('tbl_request').update({'starttime': startTime, 'status': 3}).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    await sendPushNotification(
      booking['tbl_client']['fcm_token'],
      'Job Started',
      'Your job has started on ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(startTime))}.',
      booking,
    );
    fetchData();
  }

  void _endJob(int bookingId, double charge) async {
    DateTime end = DateTime.now();
    await supabase.from('tbl_request').update({
      'endtime': end.toIso8601String(),
      'charge': charge,
      'status': 5
    }).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    String formattedEndTime = DateFormat('hh:mm a').format(end);
    await sendPushNotification(booking['tbl_client']['fcm_token'], 'Job Ended',
        'Your job has ended at $formattedEndTime. Charge: \$$charge.', booking);
    fetchData();
  }

  void _markPaymentCompleted(int bookingId) async {
    await supabase.from('tbl_request').update({'status': 6}).match({'id': bookingId});
    final booking = bookings.firstWhere((b) => b['id'] == bookingId);
    await sendPushNotification(booking['tbl_client']['fcm_token'], 'Payment Completed',
        'Your payment has been completed.', booking);
    fetchData();
  }
}