import 'dart:io';
import 'package:clients/components/form_validation.dart';
import 'package:clients/main.dart';
import 'package:clients/screen/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Myregister extends StatefulWidget {
  const Myregister({super.key});

  @override
  State<Myregister> createState() => _MyregisterState();
}

class _MyregisterState extends State<Myregister> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Map<String, dynamic>> districtList = [];
  String? selectedDistrict;

  List<Map<String, dynamic>> placeList = [];
  String? selectedPlace;
  File? _image;

  Future<void> register() async {
    try {
      final authentication = await supabase.auth.signUp(
        password: _passwordController.text,
        email: _emailController.text,
      );
      String uid = authentication.user!.id;
      signUp(uid);
    } catch (e) {
      print("Error: $e");
    }
  }

  void signUp(String uid) async {
    try {
      await supabase.from('tbl_client').insert([
        {
          'id': uid,
          'client_name': _nameController.text,
          'client-address': _addressController.text,
          'client_email': _emailController.text,
          'client_contact': _phoneController.text,
          'client_password': _passwordController.text,
          'place_id': selectedPlace,
        }
      ]);
      print("Data inserted successfully.");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchPlaces(String districtId) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('district_id', districtId);
      setState(() {
        placeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 128, 128),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.2),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Client Information",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 128, 128),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(_nameController, 'Name', Icons.person, FormValidation.validateName),
                      _buildTextField(_addressController, 'Address', Icons.home, FormValidation.validateAddress),
                      _buildTextField(_emailController, 'Email', Icons.email, FormValidation.validateEmail),
                      _buildTextField(_phoneController, 'Phone Number', Icons.phone, FormValidation.validateContact),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: districtList
                                .any((d) => d['id'].toString() == selectedDistrict)
                            ? selectedDistrict
                            : null,
                        items: districtList.map((district) {
                          return DropdownMenuItem<String>(
                            value: district['id'].toString(),
                            child: Text(district['district_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            selectedPlace = null; // Reset place when district changes
                            fetchPlaces(value!);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select District',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: placeList
                                .any((p) => p['id'].toString() == selectedPlace)
                            ? selectedPlace
                            : null,
                        items: placeList.map((place) {
                          return DropdownMenuItem<String>(
                            value: place['id'].toString(),
                            child: Text(place['place_name']),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedPlace = value),
                        decoration: InputDecoration(
                          labelText: 'Select Place',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildTextField(
                        _passwordController,
                        'Password',
                        Icons.lock,
                        FormValidation.validatePassword,
                        obscureText: true,
                      ),
                      _buildTextField(
                        _confirmPasswordController,
                        'Confirm Password',
                        Icons.lock_outline,
                        (value) => FormValidation.validateConfirmPassword(value, _passwordController.text),
                        obscureText: true,
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 128, 128),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 5,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print("Registration Successful");
                            register();
                            Navigator.push(context,MaterialPageRoute(builder:(context)=>Mylogin()));
                          }
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(230, 255, 252, 197),
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 0, 128, 128)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}