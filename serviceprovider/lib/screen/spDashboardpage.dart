import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/changepass.dart';
import 'package:serviceprovider/screen/complaintpage.dart';
import 'package:serviceprovider/screen/editprofile.dart';
import 'package:serviceprovider/screen/loginpage.dart';
import 'package:serviceprovider/screen/notification.dart';
import 'package:serviceprovider/screen/requestview.dart';
import 'package:serviceprovider/screen/viewComplaints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_colors/awesome_colors.dart';
import 'package:geolocator/geolocator.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool isLoading = true;
  Map<String, dynamic> spdetails = {};
  int unreadCount = 0; // Track unread notification count

  final Color primaryColor = const Color.fromRGBO(29, 51, 74, 1);
  final Color accentColor = const Color.fromARGB(255, 86, 130, 3);
  final Color backgroundColor = Whites.signalWhite;

  Future<void> _updateProviderLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await supabase.from('tbl_sp').update({
        'fcm_token': fcmToken,
        'sp_location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      }).eq('id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated successfully')),
      );
    } catch (e) {
      print("Error location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating location')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _updateProviderLocation();
    fetchUnreadNotifications(); // Fetch unread count
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabase
          .from("tbl_sp")
          .select("*,tbl_place(*,tbl_district(*))")
          .eq("id", supabase.auth.currentUser!.id)
          .single();
      print("Fetched data: $response");
      setState(() {
        spdetails = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUnreadNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('tbl_notification')
          .select('is_read')
          .eq('sp_id', userId ?? '')
          .eq('reciever', 'SP')
          .eq('is_read', false);

      setState(() {
        unreadCount = response.length; // Count of unread notifications
      });
    } catch (e) {
      print("Error fetching unread notifications: $e");
      setState(() => unreadCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80),
            Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 60),
            // Inbox with Badge
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                ).then((_) {
                  // Refresh unread count after returning
                  fetchUnreadNotifications();
                });
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.message,
                        color: Colors.white,
                      ),
                      Text(
                        'Inbox',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (unreadCount > 0) // Show badge only if there are unread notifications
                    Positioned(
                      right: -5,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
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
              ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(29, 51, 74, 1),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, right: 3),
                              child: GestureDetector(
                                onTap: () {
                                  supabase.auth.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Mylogin()),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      size: 30,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: spdetails['sp_photo'] != null
                                ? NetworkImage(spdetails['sp_photo'])
                                : null,
                            backgroundColor: primaryColor,
                            child: spdetails['sp_photo'] == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Welcome, ${spdetails['sp_name'] ?? "Service Provider"}!',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            spdetails['sp_description'] ??
                                'Providing quality services with excellence.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "My Account",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 180),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Editpro()),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.edit,
                                      size: 30,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      "Edit",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.deepOrange,
                            thickness: 2,
                            endIndent: 200,
                          ),
                          const SizedBox(height: 10),
                          InfoRow(
                            label: "Name",
                            value: spdetails["sp_name"] ?? "No name",
                          ),
                          InfoRow(
                            label: "Address",
                            value: spdetails["sp_address"] ?? "No address",
                          ),
                          InfoRow(
                            label: "Email",
                            value: spdetails["sp_email"] ?? "No email",
                          ),
                          InfoRow(
                            label: "Phone",
                            value: spdetails["sp_contact"] ?? "No contact",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.5,
                      children: [
                        _buildButton(context, Icons.list, "View Requests", RequestView()),
                        _buildButton(context, Icons.lock, "Change Password", passwordChange()),
                        _buildButton(context, Icons.report, "Report Complaint", ComplaintPage()),
                        _buildButton(context, Icons.feedback, "My Complaint", ViewComplaint()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildButton(BuildContext context, IconData icon, String label, Widget page) {
  return InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 146, 144, 214).withOpacity(0.9),
            const Color.fromARGB(255, 138, 191, 198).withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      padding: EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}