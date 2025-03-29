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

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_district').delete().eq('id', id);
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
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
               width: 90, // Reduce this value
         height: 700, // Reduce this value
        decoration: BoxDecoration(
          color:  Color.fromARGB(255, 255, 250, 250),
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
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            IntrinsicWidth(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: dname,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'District Name',
                        hintText: 'Enter district name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 57, 51, 107), // Button color
                        foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Add District"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(
              color: const Color.fromARGB(255, 57, 51, 107),
              thickness: 2,
            ),
            SizedBox(height: 16),
            Text( "District List", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: DistrictList.length,
                      itemBuilder: (context, index) {
                        final district = DistrictList[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              district['district_name'],
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: IconButton(
                              onPressed: () => delete(district['id']),
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ),
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