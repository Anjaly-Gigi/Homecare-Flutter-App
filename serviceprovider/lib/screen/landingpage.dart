import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:serviceprovider/screen/loginpage.dart';

class MyLanding extends StatefulWidget {
  const MyLanding({super.key});

  @override
  _MyLandingState createState() => _MyLandingState();
}

class _MyLandingState extends State<MyLanding> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _lottieAnimation;
  late Animation<double> _taglineAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _titleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)),
    );
    _lottieAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.5, curve: Curves.easeIn)),
    );
    _taglineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.75, curve: Curves.easeIn)),
    );
    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.75, 1.0, curve: Curves.easeIn)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 246, 253, 255), const Color.fromARGB(255, 0, 128, 128), Color.fromARGB(255, 246, 253, 255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _titleAnimation,
                            child: Text(
                              "HomeCare",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pacifico(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _lottieAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Lottie.asset(
                                  'assets/spc.json',
                                  fit: BoxFit.contain,
                                  height: 200,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeTransition(
                            opacity: _taglineAnimation,
                            child: Text(
                              "Bringing Trusted Hands to Every Home",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black87,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(_buttonAnimation),
                            child: FadeTransition(
                              opacity: _buttonAnimation,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Mylogin()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 8,
                                  backgroundColor: const Color(0xFFFFA726), // Orange for contrast
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Get Started",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MyLanding()));
}