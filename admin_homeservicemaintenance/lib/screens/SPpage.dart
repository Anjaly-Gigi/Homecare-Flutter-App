import 'package:admin_homeservicemaintenance/main.dart';
import 'package:admin_homeservicemaintenance/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceProviderVerification extends StatefulWidget {
  const ServiceProviderVerification({super.key});

  @override
  State<ServiceProviderVerification> createState() => _ServiceProviderVerificationState();
}

class _ServiceProviderVerificationState extends State<ServiceProviderVerification> {
  List<Map<String, dynamic>> _serviceProviderList = [];

  @override
  void initState() {
    super.initState();
    fetchServiceProviders();
  }

  // Fetch service providers with pending status (sp_vstatus = 0)
  Future<void> fetchServiceProviders() async {
    try {
      final response = await supabase.from('tbl_sp').select().eq('sp_vstatus', 0);
      setState(() {
        _serviceProviderList = response;
      });
    } catch (e) {
      print("ERROR FETCHING SERVICE PROVIDER DATA: $e");
    }
  }

  // Update the status of a service provider
  Future<void> updateServiceProviderStatus(String id, int status) async {
    try {
      await supabase.from('tbl_sp').update(
          {'sp_vstatus': status}).match({'id': id});
      fetchServiceProviders(); // Refresh the list after updating
    } catch (e) {
      print("ERROR UPDATING SERVICE PROVIDER STATUS: $e");
    }
  }

  // Accept a service provider
  void accept(String id) {
    updateServiceProviderStatus(id, 1); // Set status to 1 (Accepted)
  }

  // Reject a service provider
  void reject(String id) {
    updateServiceProviderStatus(id, 2); // Set status to 2 (Rejected)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Provider Verification"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Sl.No")),
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Email")),
            DataColumn(label: Text("Contact")),
            DataColumn(label: Text("Service Type")),
            DataColumn(label: Text("Action")),
          ],
          rows: _serviceProviderList.asMap().entries.map((entry) {
            final serviceProvider = entry.value;
            return DataRow(cells: [
              DataCell(Text((entry.key + 1).toString())),
              DataCell(Text(serviceProvider['sp_name'].toString())),
              DataCell(Text(serviceProvider['sp_email'].toString())),
              DataCell(Text(serviceProvider['sp_contact'].toString())),
              DataCell(Text(serviceProvider['service_type'].toString())),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      accept(serviceProvider['id'].toString());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      reject(serviceProvider['id'].toString());
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}