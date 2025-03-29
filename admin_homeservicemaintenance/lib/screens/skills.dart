import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ManageSkills extends StatefulWidget {
  const ManageSkills({super.key});

  @override
  State<ManageSkills> createState() => _ManageSkillsState();
}

class _ManageSkillsState extends State<ManageSkills> {
  final TextEditingController skills = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> skillsList = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  PlatformFile? pickedImage;

  // Handle File Upload Process
  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload() async {
    try {
      final bucketName = 'skill'; // Replace with your bucket name
      final filePath = "SkillImage-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.from('tbl_skills').select();
      print("Fetched data: $response");
      setState(() {
        skillsList = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submit() async {
    try {
      String? imageUrl = await photoUpload();
      await supabase.from('tbl_skills').insert([
        {'skill_name': skills.text, 'skill_image': imageUrl}
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Inserted")),
      );

      print("Data Inserted");
      skills.clear();
      await fetchData();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_skills').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Deleted")),
      );
      print("Deleted");
      fetchData();
    } catch (e) {
      print("Error Deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 90, // Reduce this value
        height: 700, // Reduce this value
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          color: Color.fromRGBO(241, 243, 251, 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                    child: pickedImage == null
                        ? GestureDetector(
                            onTap: handleImagePick,
                            child: Icon(
                              Icons.add_a_photo,
                              color: Color(0xFF0277BD),
                              size: 50,
                            ),
                          )
                        : GestureDetector(
                            onTap: handleImagePick,
                            child: ClipRRect(
                              child: pickedImage!.bytes != null
                                  ? Image.memory(
                                      Uint8List.fromList(
                                          pickedImage!.bytes!), // For web
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(pickedImage!
                                          .path!), // For mobile/desktop
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: TextFormField(
                            controller: skills,
                            decoration: InputDecoration(
                              labelText: 'Skill Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: const Color.fromARGB(255, 57, 51, 107), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color:  const Color.fromARGB(255, 57, 51, 107), width: 2),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  const Color.fromARGB(255, 57, 51, 107), // Button color
                            foregroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Add Skill",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Divider(
                thickness: 2,
                color: const Color.fromARGB(255, 57, 51, 107),
              ),
              SizedBox(height: 16),
              Text(
                "List of Skills",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 57, 51, 107)),
              ),
              SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: skillsList.length,
                        itemBuilder: (context, index) {
                          final skill = skillsList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(skill['skill_image'] ?? ""),
                            ),
                            title: Text(skill['skill_name']),
                            // subtitle: Text(skill['id'].toString()),
                            trailing: IconButton(
                                onPressed: () {
                                  delete(skill['id']);
                                },
                                icon: Icon(Icons.delete_outline)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


