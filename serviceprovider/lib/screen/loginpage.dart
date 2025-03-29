import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviceprovider/components/form_validation.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/registrationpage.dart';
import 'package:serviceprovider/screen/spDashboardpage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Mylogin extends StatefulWidget {
  const Mylogin({super.key});

  @override
  State<Mylogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Mylogin> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isVisible = true;

  void _submit() {
    if (formKey.currentState!.validate()) {
      print("Validation successful");
    }
  }

  Future<void> login() async {
    try {
      final auth = await supabase.auth
          .signInWithPassword(password: password.text, email: email.text);
      String id = auth.user!.id;
      final response = await supabase.from('tbl_sp').select().eq('id', id);

      if (response.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashBoard(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid email or password'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateProviderLocation() async {
    try {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FAFC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('assets/sp1.jpg'),
          //   fit: BoxFit.fitHeight,
          // ),
        ),
       
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.all(35),
            children: [
               SizedBox(width: 50),
              Column(
                children: [
                  Image.asset('assets/sp1.jpg'),
                  Text(
                    '  Welcome back',
                    style: GoogleFonts.openSans(
                      fontSize: 30,
                      color: const Color.fromARGB(255, 0, 128, 128),
                      textStyle: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Login to your account',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 15,
                        color: const Color.fromARGB(255, 205, 92, 92),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (value) => FormValidation.validateEmail(value),
                      controller: email,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 75, 0, 130),
                            width: 1,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 75, 0, 130),
                            width: 2,
                          ),
                        ),
                        hintText: "Enter email",
                        labelText: "Email",
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 75, 0, 130)),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (value) =>
                          FormValidation.validatePassword(value),
                      controller: password,
                      obscureText: _isVisible,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 75, 0, 130),
                            width: 1,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 75, 0, 130),
                            width: 2,
                          ),
                        ),
                        hintText: "Enter Password",
                        labelText: "Password",
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 75, 0, 130)),
                        prefixIcon: Icon(Icons.password_sharp),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: Icon(
                            _isVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 128, 128),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    onPressed: () {
                      _submit();
                      login();
                    },
                    child: Text("Log in"),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "If you do not have an account,",
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Myregister(),
                              ),
                            );
                          },
                          child: Text(
                            "Create Account",
                            style: GoogleFonts.lato(
                              color: Color.fromARGB(255, 24, 56, 111),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
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
