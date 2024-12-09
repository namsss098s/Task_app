import 'package:final_exam/HomeScreen.dart';
import 'package:flutter/material.dart';

class ContractScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.purple[70],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Let's make a contract",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),

            // List of tasks
            Text(
              'I will:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListItem('🌟 Plan tasks.'),
                _buildListItem('🎯 Set goals.'),
                _buildListItem('🏃‍♂️ Take breaks.'),
                _buildListItem('📚 Move and refresh.'),
                _buildListItem('📝 Prioritize.'),
                _buildListItem('❌ Break tasks down.'),
                _buildListItem('🚫 No multitasking.'),
                _buildListItem('📵 Minimize distractions.'),
                _buildListItem('⏰ Limit social media.'),
              ],
            ),
            SizedBox(height: 20),

            // I Agree Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle agreement logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You agreed to the contract!')),
                  );
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[70],
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: Text(
                  'I AGREE',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.cyan,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create list items
  Widget _buildListItem(String text) {
    return Row(
      children: [
        Icon(Icons.check, color: Colors.green, size: 18),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
