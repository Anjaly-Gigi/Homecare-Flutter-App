import 'package:flutter/material.dart';
import 'package:serviceprovider/main.dart';
import 'package:serviceprovider/screen/loginpage.dart';

class AddSkills extends StatefulWidget {
  const AddSkills({super.key});

  @override
  _AddSkillsState createState() => _AddSkillsState();
}

class _AddSkillsState extends State<AddSkills> {
  List<Map<String, dynamic>> skillList = [];
  List<int> selectedSkills = [];
  bool isLoading = false;

  Future<void> fetchSkills() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('tbl_skills').select();
      setState(() => skillList = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print("Error fetching skills: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void toggleSkill(int id) {
    setState(() {
      selectedSkills.contains(id) ? selectedSkills.remove(id) : selectedSkills.add(id);
    });
  }

  Future<void> addSkill() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      for (int skillId in selectedSkills) {
        await supabase.from('tbl_spskills').insert({'sp_id': uid, 'skill_id': skillId});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skills added successfully!')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => Mylogin(),));
    } catch (e) {
      print("Error adding skills: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add skills.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Skills')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Your Skills",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: skillList.map((skill) {
                          final isSelected = selectedSkills.contains(skill['id']);
                          return ChoiceChip(
                            label: Text(
                              skill['skill_name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            onSelected: (_) => toggleSkill(skill['id']),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: selectedSkills.isNotEmpty ? Colors.blue : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: selectedSkills.isEmpty ? null : addSkill,
                      child: const Text("Submit Skills", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
