import 'package:clients/screen/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
 

class Mylanding extends StatelessWidget {
  const Mylanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 143, 143),
      //  const Color.fromARGB(255, 255, 236, 183),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              child: Lottie.asset(
                'assets/LandingAnimation.json',
                fit: BoxFit.cover,
                height: 50,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.elliptical(500, 300))
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Text(
                    "Fix it fast, hire the best",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abel
         
                    (
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: const Color.fromARGB(255, 205, 92, 92),
                    ),
                  ),
                  Text(
                    "Home services at your fingertips!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.arvo(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: const Color.fromARGB(255, 75, 0, 130),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Mylogin(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      
                      backgroundColor: const Color.fromARGB(
                          255, 255, 255, 255), // Button background color
                      foregroundColor:
                         const Color.fromARGB(255, 0, 128, 128), // Text color
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                            color:const Color.fromARGB(255, 0, 139, 139),
                          )
                    ),
                    child: Text("Get Started"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
