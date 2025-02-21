import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:news_app/screens/news_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  String searchQuery = '';
  String sortBy = 'publishedAt'; // Default sorting
  String selectedSource = ''; // News source
  String selectedDate = ''; // Selected date

  List<String> sortOptions = ['relevancy', 'popularity', 'publishedAt'];
  List<String> newsSources = [
    '', // Empty means no filter
    'bbc-news',
    'cnn',
    'the-verge',
    'al-jazeera-english'
  ];

  Future<List> getNews() async {
    String apiUrl;

    if (searchQuery.isEmpty) {
      apiUrl = 'https://newsapi.org/v2/top-headlines?'
          'country=us&'
          'sortBy=$sortBy&'
          '${selectedSource.isNotEmpty ? 'sources=$selectedSource&' : ''}'
          '${selectedDate.isNotEmpty ? 'from=$selectedDate&to=$selectedDate&' : ''}'
          'apiKey=0d32c5fe88ce4a5fbff67e636892c473';
    } else {
      apiUrl = 'https://newsapi.org/v2/everything?'
          'q=$searchQuery&'
          'sortBy=$sortBy&'
          '${selectedSource.isNotEmpty ? 'sources=$selectedSource&' : ''}'
          '${selectedDate.isNotEmpty ? 'from=$selectedDate&to=$selectedDate&' : ''}'
          'language=en&'
          'apiKey=$apiKey';
    }

    final response = await http.get(Uri.parse(apiUrl));

    print("API Response Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['articles'];
    } else {
      throw Exception('Failed to load news: ${response.body}');
    }
  }



  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025,1,2),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('N E W S')),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Search News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.blue)),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(hintText: 'Enter topic'),
                onSubmitted: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: sortBy,
                items: sortOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    sortBy = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Select News Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedSource,
                items: newsSources.map((source) {
                  return DropdownMenuItem(value: source, child: Text(source.isEmpty ? 'Any' : source));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSource = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(selectedDate.isEmpty ? 'Pick a date' : selectedDate),
                onPressed: () => _selectDate(context),
              ),

              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('SEARCH'),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: getNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List articles = snapshot.data!;
            return articles.isEmpty
                ? const Center(child: Text('No articles found.'))
                : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                var article = articles[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsScreen(article: article),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(article['title'] ?? 'No Title'),
                      subtitle: Text(article['description'] ?? 'No Data'),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('NO DATA AVAILABLE'));
        },
      ),
    );
  }
}
