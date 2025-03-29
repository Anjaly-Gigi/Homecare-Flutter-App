import 'package:clients/main.dart';
import 'package:flutter/material.dart';
import 'package:clients/screen/editprofile.dart';
import 'package:clients/screen/changePassword.dart';
import 'package:clients/screen/complaintpage.dart';
import 'package:clients/screen/viewComplaints.dart';
import 'package:clients/screen/bookDetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({super.key});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  bool isLoading = true;
  Map<String, dynamic> clientData = {};

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('tbl_client')
          .select("*, tbl_place(*, tbl_district(*))")
          .eq('id', Supabase.instance.client.auth.currentUser!.id)
          .single();
      setState(() {
        clientData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6F61),
              const Color.fromARGB(255, 255, 160, 151),                       
              const Color.fromARGB(255, 175, 238, 238),
              const Color.fromARGB(255, 24, 141, 141), 
            ], // Adjust colors as needed
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text('Profile', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 10),
            _buildProfileOptions(),
            _buildLogoutButton(),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildHeader() {
    return Column (
      children: [    
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:  [
               Colors.transparent,
                Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            )
          ),
            child: Column(
              children: [  
                SizedBox(height: 30,),
                CircleAvatar(
              radius: 55,
                      backgroundColor:  const Color.fromARGB(255, 24, 141, 141), 
                      child: Text(
                        clientData.isNotEmpty ? clientData['client_name'][0] : '?',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  clientData['client_name'] ?? 'User Name',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 3, 3),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "View full profile",
                  style: TextStyle(color: Color.fromARGB(255, 58, 38, 38), fontSize: 14),
                ),
              ],
            ),
         
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
                          _buildDetailRow(Icons.email, 'Email', clientData['client_email'] ?? 'No Email'),
                          _buildDetailRow(Icons.location_on, 'Address', clientData['client_address'] ?? 'No Address'),
                          _buildDetailRow(Icons.phone, 'Contact', clientData['client_contact'].toString() ?? 'No Contact'),
                          _buildDetailRow(Icons.place, 'Place', clientData['tbl_place']?['place_name'] ?? 'No Place'),
                         
                     
         _profileOption("Edit Profile", Icons.edit, () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Editpro())),),
         
          _profileOption("My Bookings", Icons.book, () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyBooking())),),
          _profileOption(" Change Password", Icons.lock, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => passwordChange()));
          }),
          _profileOption("Report Complaint",  Icons.report, () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ComplaintPage())),),

          _profileOption("My Complaints", Icons.find_in_page_rounded, () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ViewComplaint())),
                ),
        ],
      ),
    );
  }

  Widget _profileOption(String text, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:  const Color.fromARGB(255, 221, 133, 125), 
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color.fromARGB(255, 3, 3, 3)),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () async {
          await Supabase.instance.client.auth.signOut();
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0) ,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.back_hand_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text("Back to Dashboard", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

 Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 50),
      child: Center(
    
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 10, 11, 11), size: 25),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color.fromARGB(137, 0, 0, 0))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
     

