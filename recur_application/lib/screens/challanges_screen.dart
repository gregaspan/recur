import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'bottom_navigation_bar.dart';
import 'package:recur_application/services/notif_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class Challenge {
  final String title;
  final String imageUrl;
  bool isCompleted;

  Challenge({
    required this.title,
    required this.imageUrl,
    this.isCompleted = false,
  });
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  final List<Challenge> challenges = [];
  final Random _random = Random();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChallenges();
  }

  void _initializeChallenges() async {
    List<String> initialTitles = [
      'Drink 2L of water daily for a week',
      'Wake up at 6 AM for 7 days',
      'Read 10 pages of a book every day',
      'Meditate for 5 minutes daily',
    ];

    List<Challenge> loadedChallenges = [];
    for (var title in initialTitles) {
      String imageUrl = await _fetchImageFromUnsplash(title);
      loadedChallenges.add(Challenge(
        title: title,
        imageUrl: imageUrl,
      ));
    }

    setState(() {
      challenges.addAll(loadedChallenges);
      _isLoading = false;
    });
  }

  Future<String> _fetchImageFromUnsplash(String query) async {
    const String accessKey = 'AOu9haU-42iscuMwI0-7xh1eoHt-4VVRoJtOJcWSXjk';
    try {
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/search/photos?query=$query&per_page=20'),
        headers: {'Authorization': 'Client-ID $accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[_random.nextInt(results.length)]['urls']['small'];
        }
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
    return 'https://via.placeholder.com/150';
  }

  void _onChallengeDone(int index) {
    setState(() {
      challenges[index].isCompleted = true;
    });
    _confettiController.play();
  }

  Future<void> _addNewChallenge() async {
    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AddChallengeDialog(),
    );
    
    if (newTitle != null && newTitle.isNotEmpty) {
      String imageUrl = await _fetchImageFromUnsplash(newTitle);
      setState(() {
        challenges.add(Challenge(
          title: newTitle,
          imageUrl: imageUrl,
        ));
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _testNotification() async {
    await NotificationService().showNotification(
      title: 'Test Notification', 
      body: 'Notification works!'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewChallenge,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: challenges.length,
                  itemBuilder: (context, index) {
                    final challenge = challenges[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            challenge.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: challenge.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: challenge.isCompleted
                              ? null
                              : () => _onChallengeDone(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: challenge.isCompleted
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            challenge.isCompleted ? 'Done!' : 'Done',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
        },
      ),
    );
  }
}

class AddChallengeDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddChallengeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Challenge'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter challenge title',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}