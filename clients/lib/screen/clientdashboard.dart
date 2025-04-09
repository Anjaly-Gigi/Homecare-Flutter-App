import 'package:clients/main.dart';
import 'package:clients/screen/clientprofilepage.dart';
import 'package:clients/screen/loginpage.dart';
import 'package:clients/screen/skillselection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  bool isLoading = true;
  List<Map<String, dynamic>> skillList = [];
  String name = "";

  @override
  void initState() {
    fetchSkills();
    fetchUser();
    super.initState();
  }

  Future<void> fetchSkills() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('tbl_skills').select();
      setState(() {
        skillList = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchUser() async {
    try {
      final response = await supabase
          .from('tbl_client')
          .select('client_name')
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() => name = response['client_name']);
    } catch (e) {
      print("Error Fetcing User: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
               const Color(0xFFFF6F61),
              const Color.fromARGB(255, 255, 160, 151),                       
              const Color.fromARGB(255, 175, 238, 238),
              const Color.fromARGB(255, 24, 141, 141), 
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, right: 20),
        child: GestureDetector(
          onTap: () {
            supabase.auth.signOut();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Mylogin()));
          },
          child: Column(
            children: [
              const Icon(
                Icons.logout,
                size: 30,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              Text(
                "Logout",
                style: GoogleFonts.pacifico(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
              Center(
                child: Text(
                  "HomeCare",
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
             
       
              const SizedBox(height: 35),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context) => ClientProfile()));
                      },
                    child:CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color.fromARGB(255, 24, 141, 141), 
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome, $name",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text(
                              "Find and book top-rated service providers",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // const SizedBox(height: 20),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(context, MaterialPageRoute(builder: (context) => Nearestsp()));
                    
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color.fromARGB(255, 24, 141, 141), 
              //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: const Text(
              //       'Search for Nearest Service Provider',
              //       style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              const Text("Choose a Skill",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: skillList.length,
                        itemBuilder: (context, index) {
                          final skills = skillList[index];
                          return SkillCard(
                            skill: skills['skill_name'],
                            image: skills['skill_image'],
                            id: skills['id'],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}

class SkillCard extends StatelessWidget {
  final String skill;
  final String image;
  final int id;

  const SkillCard({super.key, required this.skill, required this.image, required this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SkillScreen(skillId: id,))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(image,
                  height: 70, width: 70, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Text(skill,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
