import 'dart:convert';
import 'package:clients/screen/clientprofilepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:clients/main.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class Booking extends StatefulWidget {
  final String id;
  const Booking({super.key, required this.id});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController jobDpt = TextEditingController();

  bool isLoading = false;
  late Map<String, dynamic> _serviceAccountConfig;

  @override
  void initState() {
    super.initState();
    _loadServiceAccountConfig(); // Load config once during initialization
  }

  Future<void> _loadServiceAccountConfig() async {
    _serviceAccountConfig = await loadConfig();
  }

  Future<void> book() async {
    setState(() => isLoading = true);

    try {
      // Convert time to 24-hour format (HH:mm:ss)
      final timeOfDay =
          TimeOfDay.fromDateTime(intl.DateFormat('hh:mm a').parse(time.text));
      final formattedTime = intl.DateFormat('HH:mm:ss').format(
        DateTime(1, 1, 2023, timeOfDay.hour, timeOfDay.minute),
      );

      await supabase.from('tbl_request').insert([
        {
          "sp_id": widget.id,
          'fordate': intl.DateFormat('yyyy-MM-dd').format(
            intl.DateFormat('dd-MM-yyyy').parse(date.text),
          ),

          'fortime': formattedTime, // Use 24-hour format
          'description': jobDpt.text,
        }
      ]);

      final getCToken =
          await supabase.from('tbl_sp').select().eq('id', widget.id).single();

      final userToken = getCToken['fcm_token'] as String?;
      print(getCToken);
      if (userToken != null) {
        await sendPushNotification(userToken);
      }

      print("Data inserted successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking submitted successfully!")),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    // Fetch unavailable dates for the service provider
    List<DateTime> unavailableDates = await _getUnavailableDates();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      selectableDayPredicate: (DateTime date) {
        // Disable dates that are in the unavailableDates list
        return !unavailableDates.contains(date);
      },
    );

    if (pickedDate != null) {
      setState(() {
        date.text = intl.DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<List<DateTime>> _getUnavailableDates() async {
    try {
      final response = await supabase
          .from('tbl_request')
          .select('fordate')
          .eq('sp_id', widget.id);

      // Parse the response to extract dates
      return (response as List)
          .map((entry) => DateTime.parse(entry['fordate']))
          .toList();
    } catch (e) {
      print("Error fetching unavailable dates: $e");
      return [];
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        time.text = pickedTime.format(context);
      });
    }
  }

  Future<Map<String, dynamic>> loadConfig() async {
    try {
      // Adjust path based on your project structure
      final String jsonString =
          await rootBundle.loadString('assets/config.json');
      print("Config Loaded: $jsonString");
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print("Error loading config.json: $e");
      return {};
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

  Future<void> sendPushNotification(String userToken) async {
    try {
      final String serverKey = await getAccessToken();
      // Replace with your actual Firebase project ID
      const String projectId = 'homecare-9aa6a'; // Update this!
      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': userToken,
          'notification': {
            'title': 'New Booking Request',
            'body': 'You have a new booking for ${date.text} at ${time.text}',
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
        // 🔽 Insert into tbl_notification
        await supabase.from('tbl_notification').insert({
          'sp_id': widget.id, // this is a UUID
          'client_id': supabase.auth.currentUser?.id,
          'title': 'New Booking Request', // Define a default title
          'message': 'You have a new booking for ${date.text} at ${time.text}',
          'datetime': DateTime.now().toIso8601String(),
          'reciever': 'SP',
          'is_read': false,
          // Set to null if not applicable
        }).then((value) {
          print('Notification inserted successfully: $value');
        }).catchError((error) {
          print('Error inserting notification: $error');
        });
      } else {
        print(
            'Failed to send FCM message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Failed Notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 235, 252),
      appBar: AppBar(
        title: const Text(
          'Book a Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 24, 141, 141),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Color.fromARGB(221, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/work.jpg'),
                    fit: BoxFit.contain,
                    // Ensures it covers the entire container
                    colorFilter: ColorFilter.mode(
                      Colors.black54, // Adjust color and opacity here
                      BlendMode.dstATop, // Blend mode to control opacity
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 188, 188, 188)
                          .withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: date,
                      readOnly: true,
                      onTap: _pickDate,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: const TextStyle(
                            color: const Color.fromARGB(255, 24, 141, 141)),
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: const Color.fromARGB(255, 24, 141, 141)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: const Color.fromARGB(255, 24, 141, 141)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: time,
                      readOnly: true,
                      onTap: _pickTime,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Time',
                        labelStyle: const TextStyle(
                            color: const Color.fromARGB(255, 24, 141, 141)),
                        prefixIcon: const Icon(Icons.access_time,
                            color: const Color.fromARGB(255, 24, 141, 141)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: const Color.fromARGB(255, 24, 141, 141)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: 4,
                      controller: jobDpt,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Job Description',
                        labelStyle: const TextStyle(
                            color: const Color.fromARGB(255, 24, 141, 141)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: const Color.fromARGB(255, 24, 141, 141)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              book();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClientProfile()),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(221, 219, 120, 33),
                        foregroundColor: const Color.fromARGB(255, 5, 5, 5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 40,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Booking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Center(
                child: const Text(
                  'Why Choose Us?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 24, 141, 141),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We provide top-notch services with a focus on quality and customer satisfaction. Book now and experience the difference!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(137, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
