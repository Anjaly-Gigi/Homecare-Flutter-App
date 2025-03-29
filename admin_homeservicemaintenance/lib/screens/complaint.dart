import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageComplaints extends StatefulWidget {
  const ManageComplaints({super.key});

  @override
  State<ManageComplaints> createState() => _ManageComplaintsState();
}

class _ManageComplaintsState extends State<ManageComplaints> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('*, tbl_client(*), tbl_sp(*)')
          .order('date', ascending: false);

      setState(() {
        complaints = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load complaints')),
        );
      });
      setState(() => isLoading = false);
    }
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yy     hh:mm a').format(parsedDate);
  }

  Future<void> handleReply(int complaintId) async {
    await supabase.from('tbl_complaint').update({
      'reply': replyController.text,
      'status':1
    }).eq('id', complaintId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reply to complaint sent')),
    );
    Navigator.pop(context);
    fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : complaints.isEmpty
            ? const Center(child: Text('No complaints found'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  final title = complaint['title'] ?? 'No Title';
                  final content = complaint['content'] ?? 'No Content';
                  final date = complaint['date'] ?? '';
                  final complaintId = complaint['id'];

                  // Get the client or service provider name
                  final clientName = complaint['tbl_client']?['client_name'];
                  final spName = complaint['tbl_sp']?['sp_name'];
                  final submittedBy = clientName ?? spName ?? 'Unknown';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Submitted by: $submittedBy",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatDate(date),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  complaint['status'] == 1 ? Text(
                                    'Reply: ${complaint['reply']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ) : SizedBox(),
                                ],
                              ),
                              complaint['status'] == 0 ? ElevatedButton(
                                onPressed: () => showReplybox(complaintId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 36, 94),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Reply',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ) : SizedBox(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  final replyController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void showReplybox(int id){
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reply to Complaint'),
          content: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: replyController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your reply',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if(formKey.currentState!.validate()){
                  handleReply(id);
                }
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

}
