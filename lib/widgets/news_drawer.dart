import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsDrawer extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String) onSortChange;
  final Function(String) onSourceChange;
  final Function(String) onDateChange;

  const NewsDrawer({
    super.key,
    required this.onSearch,
    required this.onSortChange,
    required this.onSourceChange,
    required this.onDateChange,
  });

  @override
  State<NewsDrawer> createState() => _NewsDrawerState();
}

class _NewsDrawerState extends State<NewsDrawer> {
  TextEditingController searchController = TextEditingController();
  String sortBy = 'publishedAt';
  String selectedSource = '';
  String selectedDate = '';

  List<String> sortOptions = ['relevancy', 'popularity', 'publishedAt'];
  List<String> newsSources = ['', 'bbc-news', 'cnn', 'the-verge', 'al-jazeera-english'];

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025, 1, 2),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      widget.onDateChange(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(hintText: 'Enter query'),
              onSubmitted: (value) {
                widget.onSearch(value);
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
                widget.onSortChange(sortBy);
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
                widget.onSourceChange(selectedSource);
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
                Navigator.pop(context); // Close Drawer
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
