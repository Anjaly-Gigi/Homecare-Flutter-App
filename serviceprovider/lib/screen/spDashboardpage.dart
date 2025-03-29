import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/changepass.dart';
import 'package:serviceprovider/screen/complaintpage.dart';
import 'package:serviceprovider/screen/editprofile.dart';
import 'package:serviceprovider/screen/loginpage.dart';
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
 
  final Color primaryColor = const Color.fromRGBO(29, 51, 74, 1);
  final Color accentColor = const Color.fromARGB(255, 86, 130, 3);
  final Color backgroundColor = Whites.signalWhite;

  Future<void> _updateProviderLocation() async {
    try {
      // Check and request location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get the current user's ID from Supabase Auth
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }
  final fcmToken = await FirebaseMessaging.instance.getToken();
      // Upsert (insert or update) the location in Supabase
      await supabase.from('tbl_sp').update({
        'fcm_token':fcmToken,
        'sp_location': {
    'latitude': position.latitude,
    'longitude': position.longitude,
  },
        // Add 'name' or other fields if needed, e.g., 'name': 'John Doe'
      }).eq('id', supabase.auth.currentUser!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location updated successfully')),
      );
    } catch (e) {
      print("Error location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating location')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    _updateProviderLocation();
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

   


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(29, 51, 74, 1),
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
                          Text(
                            "My Account",
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                    Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Wrap(
      spacing: 20, // Horizontal space between buttons
      runSpacing: 20, // Vertical space between button rows
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Editpro()));
          },
          child: const Text("Edit Profile"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RequestView()));
          },
          child: const Text("View Requests"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => passwordChange()));
          },
          child: const Text("Change Password"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintPage()));
          },
          child: const Text("Report Complaint"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewComplaint()));
          },
          child: const Text("My Complaint"),
        ),
         ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>Mylogin()));
          },
          child: const Text("Log out"),
        ),
      ],
    ),
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