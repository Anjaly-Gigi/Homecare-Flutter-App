import 'package:serviceprovider/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageDistrict extends StatefulWidget {
  const ManageDistrict({super.key});

  @override
  State<ManageDistrict> createState() => _ManageDistrictState();
}

class _ManageDistrictState extends State<ManageDistrict> {
  final TextEditingController pname = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> PlaceList = [];
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
      final response = await supabase.from('tbl_place').select();
      print("Fetched data: $response");
      setState(() {
        PlaceList = List<Map<String, dynamic>>.from(response);
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
      await supabase.from('tbl_place').insert([
        {'place_name': pname.text}
      ]);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Inserted")),
      );

      print("Data Inserted");
      pname.clear();
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
                  controller: pname,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Place Name',
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
                  itemCount: PlaceList.length,
                  itemBuilder: (context, index) {
                    final dname = PlaceList[index];
                    return ListTile(
                      title: Text(dname['place_name']),
                      // subtitle: Text(skill['id'].toString()),
                    );
                  },
                ),
        ),
      ],
    );
  }
}