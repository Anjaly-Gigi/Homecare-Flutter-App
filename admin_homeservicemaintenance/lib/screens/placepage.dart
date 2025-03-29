import 'package:admin_homeservicemaintenance/main.dart';
import 'package:flutter/material.dart';

class ManagePlace extends StatefulWidget {
  const ManagePlace({super.key});

  @override
  State<ManagePlace> createState() => _ManagePlaceState();
}

class _ManagePlaceState extends State<ManagePlace> {
  final TextEditingController pname = TextEditingController();

  bool isLoading = true;
  List<Map<String, dynamic>> PlaceList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDistrict();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.from('tbl_place').select(" *, tbl_district(*)");
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
        {'place_name': pname.text,'district_id':selectedDistrict}
          
         
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

  List<Map<String, dynamic>> districtList = [];
  String? selectedDistrict;

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      print("Fetched data: $response");
      setState(() {
        districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
      setState(() {});
    }
  }

  Future<void> delete(int id) async {
    try{
      await supabase.from('tbl_place').delete().eq('id', id);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                children: [
                  Expanded(
                      child: DropdownButtonFormField(
                    value: districtList
                            .any((district) => district['id'] == selectedDistrict)
                        ? selectedDistrict
                        : null,
                    items: districtList.map((district) {
                      return DropdownMenuItem(
                        value: district['id'],
                        child: Text(district['district_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value.toString();
                      });
                    },
                  )),
                  Expanded(
                    child: TextFormField(
                      controller: pname,
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor:  const Color.fromARGB(255, 57, 51, 107), // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                        final pname = PlaceList[index];
                        return ListTile(
                          title: Text(pname['place_name'] ?? 'Unknown Place'),
                          subtitle: Text(pname['tbl_district']['district_name'] ?? ""),
                          trailing: IconButton(
                              onPressed: () {
                                delete(pname['id']);
                              },
                              icon: Icon(Icons.delete_outline)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
