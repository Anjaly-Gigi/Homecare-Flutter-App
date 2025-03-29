
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageDistrict extends StatefulWidget {
  const ManageDistrict({super.key});

  @override
  State<ManageDistrict> createState() => _ManageDistrictState();
}

class _ManageDistrictState extends State<ManageDistrict> {
  final TextEditingController dname = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> DistrictList = [];
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.from('tbl_district').select();
      print("Fetched data: $response");
      setState(() {
        DistrictList = List<Map<String, dynamic>>.from(response);
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
      await supabase.from('tbl_district').insert([
        {'district_name': dname.text}
      ]);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Inserted")),
      );

      print("Data Inserted");
      dname.clear();
      await fetchData();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(28.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: dname,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'District Name',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: submit,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: DistrictList.length,
                  itemBuilder: (context, index) {
                    final dname = DistrictList[index];
                    return ListTile(
                      title: Text(dname['district_name']),
                      // subtitle: Text(skill['id'].toString()),
                    );
                  },
                ),
        ),
      ],
    );
  }
}