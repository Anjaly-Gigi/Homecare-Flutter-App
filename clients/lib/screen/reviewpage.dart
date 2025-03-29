import 'package:flutter/material.dart';

class JobReviewPage extends StatefulWidget {
  @override
  _JobReviewPageState createState() => _JobReviewPageState();
}

class _JobReviewPageState extends State<JobReviewPage> {
  double rating = 0;
  List<String> tags = ["Professional", "Good job", "Super", "Great", "I recommend it", "Wonderful"];
  List<String> selectedTags = [];
  TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        backgroundColor: Color.fromARGB(255, 0, 128, 128),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/worker.jpg'),
                  ),
                  const SizedBox(height: 8),
                  const Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Electrician | Plumber', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Job is done successfully', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Rate your experience with John', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: tags.map((tag) => ChoiceChip(
                label: Text(tag),
                selected: selectedTags.contains(tag),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedTags.add(tag);
                    } else {
                      selectedTags.remove(tag);
                    }
                  });
                },
                selectedColor: Color.fromARGB(255, 0, 128, 128),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(color: selectedTags.contains(tag) ? Colors.white : Colors.black),
              )).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your feedback...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Rating: $rating');
                    print('Tags: $selectedTags');
                    print('Feedback: ${feedbackController.text}');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 0, 128, 128)),
                  child: const Text('Send Review'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
