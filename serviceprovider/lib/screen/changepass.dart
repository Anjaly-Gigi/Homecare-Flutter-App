import 'package:serviceprovider/components/form_validation.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class passwordChange extends StatefulWidget {
  const passwordChange({super.key});

  @override
  State<passwordChange> createState() => _passwordChangeState();
}

class _passwordChangeState extends State<passwordChange> {

   final _formKey = GlobalKey<FormState>();
   final TextEditingController _passwordController = TextEditingController();
      final TextEditingController _newpasswordController = TextEditingController();
         final TextEditingController _conpasswordController = TextEditingController();
   

  String? spId;

  @override
  void initState() {
    super.initState();
    fetchLoggedInClientId(); 
  }

  void fetchLoggedInClientId() async {
    try {
      
      final user = supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          spId = user.id; 
        });
        fetchData(); 
      } else {
        print('Error: No user is currently logged in.');
      }
    } catch (e) {
      print('Error fetching logged-in user ID: $e');
    }
  }

 
  void fetchData() async {
    if (spId == null) {
      print('Error: Client ID is null.');
      
    }

    try {

      final response = await supabase
          .from('tbl_sp')
          .select()
          .eq('id', spId!)
          .single();

     
      if (response != null) {
        setState(() {
         _newpasswordController.text = response['sp_password'];
          
        });
      } else {
        print('Error: No data found for the client ID: $spId');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> submit() async {
  if (spId == null) {
    print('Error: Client ID is null.');
    return;
  }

  
  if (_formKey.currentState!.validate()) {
    // Check if new password and confirm password match
    if (_newpasswordController.text != _conpasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password and confirm password do not match")),
      );
      return;
    }

    try {
     
      final response = await supabase.auth.updateUser(
        UserAttributes(password: _newpasswordController.text),
      );

      if (response.user != null) {
      
        await supabase.from('tbl_client').update({
          'client_password': _newpasswordController.text,
        }).eq('id', spId!);

        print("Password updated successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully")),
        );

        // Navigate to the login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Mylogin()),
        );
      } else {
        print("Error updating password");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating password")),
        );
      }
    } catch (e) {
      print("Error updating password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating password: $e")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Change Password",
         style: TextStyle(
          fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255)
         ),
        ),
        backgroundColor: const Color.fromARGB(255, 250, 141, 52),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child:Form (
                  key:_formKey ,
                  child: Column(
                   children: [
                    Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 128, 128),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                       Image.asset(
                'assets/key.png',
                height: 150,
                width: 150,
              ),

               const SizedBox(height: 30),
                  
                      _buildTextField(_passwordController, 'Old Password', Icons.password, FormValidation.validateName),
                       _buildTextField(_newpasswordController, 'New Password', Icons.password, FormValidation.validateName),
                      _buildTextField(_conpasswordController, 'New Password', Icons.password, FormValidation.validateName),
                      

                      const SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 128, 128),
                          padding: const EdgeInsets.symmetric(vertical: 14,horizontal:24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 5,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print("Passsword reset Successful");
                            submit();
                          }
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(230, 255, 252, 197),
                          ),
                        ),
                      ),

                   ],
                  )),
              )
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