import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../firebase.dart';

class ResultScreen extends StatefulWidget {
  final String questionnaireId;
  final String title;

  ResultScreen({required this.questionnaireId, required this.title});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, List<Map<String, dynamic>>> categorizedQuestions = {};
  Map<String, List<Map<String, dynamic>>> categorizedResults = {};
  late TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      // Load questions
      Map<String, List<Map<String, dynamic>>> questions = await _firebaseService
          .getAllQuestionsGroupedByCategory(widget.questionnaireId);

      // Load responses
      List<Map<String, dynamic>> responses =
          await _firebaseService.getResponses(widget.questionnaireId);

      // Process responses
      Map<String, List<Map<String, dynamic>>> processedResults = {};
      for (var category in questions.keys) {
        processedResults[category] = [];
        for (var question in questions[category]!) {
          Map<String, dynamic> questionResults = {
            'id': question['id'],
            'text': question['text'],
            'results': {},
            'comments': [],
          };
          processedResults[category]!.add(questionResults);
        }
      }

      // Aggregate responses
      for (var response in responses) {
        String questionId = response['questionId'];
        String selectedOption = response['response'];
        String? comment = response['comment'];

        for (var category in processedResults.keys) {
          var questionIndex = processedResults[category]!
              .indexWhere((q) => q['id'] == questionId);
          if (questionIndex != -1) {
            var questionResults = processedResults[category]![questionIndex];
            questionResults['results'][selectedOption] =
                (questionResults['results'][selectedOption] ?? 0) + 1;
            if (comment != null && comment.isNotEmpty) {
              questionResults['comments'].add(comment);
            }
            break;
          }
        }
      }

      setState(() {
        categorizedQuestions = questions;
        categorizedResults = processedResults;
        _tabController = TabController(
            length: categorizedQuestions.keys.length, vsync: this);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading results: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load results. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results: ${widget.title}'),
        bottom: isLoading
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: categorizedQuestions.keys
                    .map((category) => Tab(text: category))
                    .toList(),
              ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: categorizedResults.entries.map((entry) {
                return _buildCategoryResults(entry.key, entry.value);
              }).toList(),
            ),
    );
  }

  Widget _buildCategoryResults(
      String category, List<Map<String, dynamic>> questions) {
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionResult(questions[index]);
      },
    );
  }

  Widget _buildQuestionResult(Map<String, dynamic> question) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'] ?? 'Unknown Question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildChartSection(question),
            SizedBox(height: 16),
            Text(
              'Comments:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ..._buildCommentsList(question['comments'] ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(Map<String, dynamic> question) {
    Map<String, int> results = Map<String, int>.from(question['results'] ?? {});
    if (results.isEmpty) {
      return Text('No responses yet.');
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: _generatePieChartSections(results),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildLegend(results),
      ],
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      Map<String, int> results) {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple
    ];
    int totalResponses = results.values.fold(0, (sum, count) => sum + count);

    return results.entries.map((entry) {
      double percentage =
          totalResponses > 0 ? (entry.value / totalResponses) * 100 : 0;
      return PieChartSectionData(
        color: colors[results.keys.toList().indexOf(entry.key) % colors.length],
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, int> results) {
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple
    ];
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: results.entries.map((entry) {
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: colors[
                results.keys.toList().indexOf(entry.key) % colors.length],
          ),
          label: Text('${entry.key}: ${entry.value}'),
        );
      }).toList(),
    );
  }

  List<Widget> _buildCommentsList(List<dynamic> comments) {
    return comments.map((comment) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text('• $comment'),
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
