import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<String>> events = {}; // Store events for each date
  DateTime selectedDate = DateTime.now(); // Currently selected date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            eventLoader: (day) => events[day] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: (events[selectedDate] ?? [])
                  .map((event) => ListTile(title: Text(event)))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEvent(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _addEvent(BuildContext context) {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Event"),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(hintText: "Enter event details"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                setState(() {
                  if (events[selectedDate] == null) {
                    events[selectedDate] = [];
                  }
                  events[selectedDate]!.add(eventController.text);
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}