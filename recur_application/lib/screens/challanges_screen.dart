import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'bottom_navigation_bar.dart';
import 'package:recur_application/services/notif_service.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  final List<String> challenges = [
    'Drink 2L of water daily for a week',
    'Wake up at 6 AM for 7 days',
    'Read 10 pages of a book every day',
    'Meditate for 5 minutes daily',
  ];

  // Tracks completion state for each challenge
  final Map<int, bool> _completedChallenges = {};

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onChallengeDone(int index) {
    setState(() {
      _completedChallenges[index] = true;
    });
    _confettiController.play();
  }

  Future<void> _testNotification() async {
    await NotificationService()
        .showNotification(title: 'Test Notification', body: 'Notification works!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: challenges.length,
                  itemBuilder: (context, index) {
                    final isDone = _completedChallenges[index] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          challenges[index],
                          style: TextStyle(
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: isDone ? null : () => _onChallengeDone(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDone
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                          ),
                          child: Text(isDone ? 'Done!' : 'Done'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _testNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Test Notifications'),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.blue, Colors.green, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation here
        },
      ),
    );
  }
}