import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviceprovider/components/form_validation.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/addskills.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedDistrict;
  String? selectedPlace;
  File? _image; // Profile image
  File? _proofFile; // Proof file
  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> placeList = [];
  String? proofFileName;

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    
  }

  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() => districtList = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchPlaces(String districtId) async {
    try {
      final response = await supabase
          .from('tbl_place')
          .select()
          .eq('district_id', districtId);
      setState(() => placeList = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _pickProofFile() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery); // For images; use file picker for PDFs
    if (pickedFile != null) {
      setState(() {
        _proofFile = File(pickedFile.path);
        proofFileName = pickedFile.name;
      });
    }
  }

  Future<void> signup() async {
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = response.user;
      if (user != null) {
        final userId = user.id;
        if (_image != null || _proofFile != null) {
          final photoUrl = _image != null
              ? await _uploadFile(_image!, userId, 'sp_images')
              : null;
          final proofUrl = _proofFile != null
              ? await _uploadFile(_proofFile!, userId, 'sp_proofs')
              : null;

          await supabase.from('tbl_sp').insert({
            'id': userId,
            'sp_name': _nameController.text,
            'sp_email': _emailController.text,
            'sp_photo': photoUrl,
            'sp_password': _passwordController.text,
            'sp_address': _addressController.text,
            'sp_contact': _phoneController.text,
            'sp_proof': proofUrl,
            'place_id': selectedPlace,
          });

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully')));
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddSkills()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please upload profile image and proof document')));
        }
      }
    } catch (e) {
      print('Sign up failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sign up failed')));
    }
  }

  Future<String?> _uploadFile(File file, String userId, String folder) async {
    try {
      final fileName =
          '${folder}_$userId${DateTime.now().millisecondsSinceEpoch}';
      await supabase.storage.from(folder).upload(fileName, file);
      final imageUrl = supabase.storage.from(folder).getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('File upload failed: $e');
      return null;
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String? Function(String?)? validator,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 0, 128, 128)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF2FAFC),
      appBar: AppBar(
        title: const Text("Create Account",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 128, 128),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Service Provider Information",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 128, 128))),
                const SizedBox(height: 20),
        
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey[800])
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
        
                _buildTextField(_nameController, 'Name', Icons.person,
                    FormValidation.validateName),
                _buildTextField(_addressController, 'Address', Icons.home,
                    FormValidation.validateAddress),
                _buildTextField(_emailController, 'Email', Icons.email,
                    FormValidation.validateEmail),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone,
                    FormValidation.validateContact),
        
                const SizedBox(height: 16),
        
                // Proof Upload Field
                GestureDetector(
                  onTap: _pickProofFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file,
                            color: Color.fromARGB(255, 0, 128, 128)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            proofFileName ?? 'Upload Proof Document',
                            style: TextStyle(
                                color: proofFileName != null
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                        ),
                        const Icon(Icons.upload_file, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
        
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
                      selectedPlace =
                          null; // Reset place when district changes
                      fetchPlaces(value!);
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select District',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
        
                const SizedBox(height: 10),
                _buildTextField(_passwordController, 'Password', Icons.lock,
                    FormValidation.validatePassword,
                    obscureText: true),
                _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock_outline,
                    (value) => FormValidation.validateConfirmPassword(
                        value, _passwordController.text),
                    obscureText: true),
        
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 128, 128),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) signup();
                  },
                  child: const Text('Register',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(230, 255, 252, 197))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
