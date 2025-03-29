import 'package:serviceprovider/components/form_validation.dart';
import 'package:serviceprovider/main.dart';
import 'package:flutter/material.dart';

class Editpro extends StatefulWidget {
  const Editpro({super.key});

  @override
  State<Editpro> createState() => _EditproState();
}

class _EditproState extends State<Editpro> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _photoController = TextEditingController();

  String? spId; // Store the logged-in client's ID

  @override
  void initState() {
    super.initState();
    fetchLoggedInClientId(); // Fetch the logged-in client's ID
  }

  // Fetch the logged-in client's ID
  void fetchLoggedInClientId() async {
    try {
      // Get the current user from Supabase Auth
      final user = supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          spId = user.id; // Set the clientId to the logged-in user's ID
        });
        fetchData(); // Fetch the client's data after setting the ID
      } else {
        print('Error: No user is currently logged in.');
      }
    } catch (e) {
      print('Error fetching logged-in user ID: $e');
    }
  }

  // Fetch the client's data using the logged-in client's ID
  void fetchData() async {
    if (spId == null) {
      print('Error: sp ID is null.');
      return;
    }

    try {
      // Fetch data from Supabase
      final response = await supabase
          .from('tbl_sp')
          .select()
          .eq('id', spId!)
          .single();

      // Check if data is fetched successfully
      if (response != null) {
        setState(() {
          _nameController.text = response['sp_name'];
          _addressController.text = response['sp_address'];
          _phoneController.text = response['sp_contact'];
          _photoController.text = response['sp_photo'];
        });
      } else {
        print('Error: No data found for the client ID: $spId');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Update the client's data
  Future<void> submit() async {
    if (spId == null) {
      print('Error: Client ID is null.');
      return;
    }

    try {
      await supabase.from('tbl_client').update({
        'client_name': _nameController.text,
        'client-address': _addressController.text,
        'client_contact': _phoneController.text,
      }).eq('id', spId!);

      print("Data updated successfully");
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data updated successfully")),);
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Account",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 250, 141, 52),
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
                  colors: [const Color.fromARGB(255, 206, 231, 232),const Color.fromARGB(255, 178, 199, 200),const Color.fromARGB(255, 206, 231, 232)],
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
                        "Edit Your Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 128, 128),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(_nameController, 'Name', Icons.person, FormValidation.validateName),
                      _buildTextField(_addressController, 'Address', Icons.home, FormValidation.validateAddress),
                      _buildTextField(_phoneController, 'Phone Number', Icons.phone, FormValidation.validateContact),

                      const SizedBox(height: 16),

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
                            print("Update Successful");
                            submit();
                          }
                        },
                        child: const Text(
                          'Update',
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