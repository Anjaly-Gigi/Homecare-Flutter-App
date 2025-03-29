import 'package:admin_homeservicemaintenance/components/SideButton.dart';
import 'package:admin_homeservicemaintenance/screens/SPpage.dart';
import 'package:admin_homeservicemaintenance/screens/adminlogin.dart';
import 'package:admin_homeservicemaintenance/screens/complaint.dart';
import 'package:admin_homeservicemaintenance/screens/dashboard.dart';
import 'package:admin_homeservicemaintenance/screens/districtpage.dart';
import 'package:admin_homeservicemaintenance/screens/placepage.dart';
import 'package:admin_homeservicemaintenance/screens/skills.dart';
import 'package:flutter/material.dart';

class Myhome extends StatefulWidget {
  const Myhome({super.key});

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.home,
      "label": "Home",
      'page': Dashboard(),
    },
    {
      "icon": Icons.graphic_eq,
      "label": "Manage Skills",
      'page': ManageSkills(),
    },
    {
      "icon": Icons.place,
      "label": "Manage District",
      'page': ManageDistrict(),
    },
    {
      "icon": Icons.maps_home_work,
      "label": "Manage Place",
      'page': ManagePlace(),
    },
    {
      "icon": Icons.person_3,
      "label": "Service Providers",
      "page": ServiceProviderVerification(),
    },
    {
      "icon": Icons.reviews,
      "label": "Manage Complaints",
      'page': ManageComplaints(),
    },
    {
      "icon": Icons.logout,
      "label": "Logout",
      "action": (BuildContext context) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Mylogin()));
      },
    },
  ];

  Widget currentPage = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(241, 243, 251, 1),
            ),
            child: SizedBox(
              child: ListView(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text("Administrator",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromARGB(255, 37, 170, 61),
                          fontSize: 25,
                          letterSpacing: 2)),
                  Image.asset(
                    'assets/Home.png',
                    height: 250,
                    width: 350,
                  ),
                  Text("Admin Panel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromARGB(255, 20, 44, 84),
                          fontSize: 20,
                          letterSpacing: 2)),
                  SizedBox(
                    height: 30,
                  ),
                  ListView.builder(
                    padding: EdgeInsets.all(10),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];

                      return GestureDetector(
                        onTap: () {
                          if (page.containsKey('action')) {
                            page['action'](context); // Execute logout function
                          } else {
                            setState(() {
                              currentPage = page['page'];
                            });
                          }
                        },
                        child: SideButton(
                          icon: page['icon'] ?? Icons.home,
                          label: page['label'] ?? "Home",
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // child: Text("Sidebar")
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: currentPage),
        )
      ],
    ));
  }
}
