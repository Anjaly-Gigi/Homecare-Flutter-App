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
   
            Color.fromARGB(255, 244, 252, 252), 
            Color.fromARGB(255, 244, 252, 252),                      
             
             
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
            _buildProfileOptions(),
            // _buildLogoutButton(),
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
    height: 100,
  width: 350,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
      
      borderRadius: BorderRadius.circular(25), // Rounded edges
      boxShadow: [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 6,
          offset: Offset(3, 3), // Soft shadow for depth
        ),
      ],
    ),
    child: Row(
                children: [  
                  SizedBox(width: 10,),
                  CircleAvatar(
                radius: 55,
                        backgroundColor:  const Color.fromARGB(255, 24, 141, 141), 
                        child: Icon(Icons.person_2, size: 60, color: Colors.white), // Placeholder icon
                  ),
                  const SizedBox(width: 10),
                
                  Text(
                    clientData['client_name'] ?? 'User Name',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 3, 3, 3),
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const Text(
                  //   "View full profile",
                  //   style: TextStyle(color: Color.fromARGB(255, 58, 38, 38), fontSize: 14),
                  // ),
                ],
              ),
  ),
const Text(
                    " ",
                    style: TextStyle(color: Color.fromARGB(255, 58, 38, 38), fontSize: 14),
                  ),
      ]   
           
          );
      
  }

  Widget _buildProfileOptions() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            height: 230,
  width: 350,
  decoration: BoxDecoration(
    color:  const Color.fromARGB(255, 255, 255, 255),
    borderRadius: BorderRadius.circular(25), // Rounded edges
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(3, 3), // Soft shadow for depth
      ),
      ],
    ),
            child: Column(
              children: [
                Text(
                  "My Profile", 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 24, 141, 141),
                  ),
                ),
                Divider(
                  color: const Color.fromARGB(255, 24, 141, 141),
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 10),
          
                
                                _buildDetailRow(Icons.email, 'Email', clientData['client_email'] ?? 'No Email'),
                                _buildDetailRow(Icons.home, 'Address', clientData['client-address'] ?? 'No Address'),
                                _buildDetailRow(Icons.phone, 'Contact', clientData['client_contact'].toString() ?? 'No Contact'),
                                _buildDetailRow(Icons.place, 'Place', clientData['tbl_place']?['place_name'] ?? 'No Place'),
              ]
            ),
          ),
       
           const SizedBox(height: 9),
           
                       
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
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 9),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 238, 236), 
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF6F61),),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(color: const Color.fromARGB(255, 24, 141, 141),  fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

//   Widget _buildLogoutButton() {
//     return Padding(
//       padding: const EdgeInsets.all(18),
//       child: GestureDetector(
//         onTap: () async {
//           await Supabase.instance.client.auth.signOut();
//           Navigator.pop(context);
//         },
//         child: Container(
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             color:const Color(0xFFFF6F61) ,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.back_hand_outlined, color:const Color.fromARGB(255, 24, 141, 141)),
//               SizedBox(width: 8),
//               Text("Back to Dashboard", style: TextStyle(color: const Color.fromARGB(255, 24, 141, 141), fontSize: 16)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

 Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 50),
      child: Center(
    
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 24, 141, 141), size: 24),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color.fromARGB(137, 0, 0, 0))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFF6F61),)),
            ),
          ],
        ),
      ),
    );
  }
}