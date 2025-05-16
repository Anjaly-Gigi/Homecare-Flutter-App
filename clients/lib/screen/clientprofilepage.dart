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
                title: const Text('Profile',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 4),

              _buildHeader(),
              _buildProfileOptions(),
              _buildProfileGrid(context),
              // _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        children: [
          // Profile Card with subtle elevation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar with gradient
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [const Color(0xFFFF6F61), Color(0xFF3A7BD5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // User Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientData['client_name'] ?? 'User Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Premium Member", // You can replace with dynamic data
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Optional: Add a small edit button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "View  Profile",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subtle spacing divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Divider(
              height: 1,
              color: Colors.grey[200],
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        children: [
          // Modern Profile Card
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with icon
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 219, 215),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: const Color.fromARGB(255, 24, 141, 141),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(width: 37),
                          Column(
                            children: [
                              IconButton(
                                  
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromARGB(255, 24, 141, 141),
                                      size: 30)
                                      ,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Editpro(),
                                          ),
                                        );
                                      }),
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                            ],
                          ),
                                  
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    color: const Color.fromARGB(255, 24, 141, 141),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildModernDetailRow(Icons.email_outlined, 'Email',
                          clientData['client_email'] ?? 'Not provided'),
                      const SizedBox(height: 12),
                      _buildModernDetailRow(Icons.home_outlined, 'Address',
                          clientData['client-address'] ?? 'Not provided'),
                      const SizedBox(height: 12),
                      _buildModernDetailRow(
                          Icons.phone_outlined,
                          'Contact',
                          clientData['client_contact']?.toString() ??
                              'Not provided'),
                      const SizedBox(height: 12),
                      _buildModernDetailRow(
                          Icons.location_on_outlined,
                          'Location',
                          clientData['tbl_place']?['place_name'] ??
                              'Not provided'),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // _profileOption(
          //   "My Bookings",
          //   Icons.book,
          //   () => Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => MyBooking())),
          // ),
          // _profileOption(
          //   "Change Password",
          //   Icons.lock,
          //   () => Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => passwordChange())),
          // ),
          // _profileOption(
          //   "Report Complaint",
          //   Icons.report,
          //   () => Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => ComplaintPage())),
          // ),
          // _profileOption(
          //   "My Complaints",
          //   Icons.find_in_page_rounded,
          //   () => Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => ViewComplaint())),
          // ),
        ],

      ),
      
    );
    
  }
}


Widget _buildProfileGrid(BuildContext context) {
  final options = [
    {
      'text': 'My Bookings',
      'icon': Icons.book_rounded,
      'action': () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyBooking())),
    },
    {
      'text': 'Change Password',
      'icon': Icons.lock_rounded,
      'action': () => Navigator.push(context, MaterialPageRoute(builder: (context) => passwordChange())),
    },
    {
      'text': 'Report Complaint',
      'icon': Icons.report_rounded,
      'action': () => Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintPage())),
    },
    {
      'text': 'My Complaints',
      'icon': Icons.find_in_page_rounded,
      'action': () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewComplaint())),
    },
  ];

  return GridView.count(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    childAspectRatio: 1.6,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
        children: options.map((option) => _buildGridOption(option, context)).toList(),
  );
}

Widget _buildGridOption(Map<String, dynamic> option, BuildContext context) {
  return GestureDetector(
    onTap: option['action'],
    child: Container(
  
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF9A9E), Color(0xFFFF6F61)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              option['icon'],
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            option['text'],
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
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

// Widget _buildDetailRow(IconData icon, String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
//     child: Center(
//       child: Row(
//         children: [
//           Icon(icon,
//               color: const Color.fromARGB(255, 24, 141, 141), size: 24),
//           const SizedBox(width: 12),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(137, 0, 0, 0))),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(value,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFFF6F61),
//                 )),
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _buildModernDetailRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromARGB(255, 24, 141, 141),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFFFF6F61),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
