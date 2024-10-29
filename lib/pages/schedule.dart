import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../colors.dart'; // Ensure AppColors.mainColor is defined here

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentWeekStart = DateTime.now(); // Starting date of the current week

  // Sample shift data (start time and end time)
  final Map<String, List<Map<String, String>>> _shifts = {
    '2024-10-28': [{'start': '6 AM', 'end': '2 PM', 'room': 'Room 1'}],
    '2024-10-29': [{'start': '2 PM', 'end': '10 PM', 'room': 'Room 4'}],
    '2024-10-30': [{'start': '6 PM', 'end': '10 PM', 'room': 'Room 4'}],
    '2024-10-31': [{'start': '10 PM', 'end': '11 PM', 'room': 'Room 4'}],
    '2024-11-01': [{'start': '10 PM', 'end': '11 PM', 'room': 'Room 4'}],
    '2024-11-02': [{'start': '2 AM', 'end': '10 AM', 'room': 'Room 4'}],
  };

  @override
  void initState() {
    super.initState();
    _setCurrentWeekStart();
  }

  // Set the starting date of the current week to the most recent Monday
  void _setCurrentWeekStart() {
    DateTime today = DateTime.now();
    int difference = today.weekday - 1; // Get the difference from Monday (1)
    _currentWeekStart = today.subtract(Duration(days: difference)); // Set to last Monday
  }

  // Function to get the dates of the week starting from the current week start
  List<DateTime> _getWeekDates() {
    return List.generate(7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  // Function to go to the previous week
  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(Duration(days: 7));
    });
  }

  // Function to go to the next week
  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7));
    });
  }

  // Method to build shift cells
  Widget _buildShiftCell(DateTime date, String timeSlot) {
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, String>>? shifts = _shifts[dateKey];

    // Extract time from the time slot
    String timeSlotPeriod = timeSlot.split(' ')[1]; // AM or PM
    int timeSlotHour = int.parse(timeSlot.split(' ')[0]);
    if (timeSlotHour == 12) timeSlotHour = 0; // Adjust for 12 AM case
    if (timeSlotPeriod == 'PM') timeSlotHour += 12; // Convert PM to 24-hour format

    // Check for shifts that overlap with the timeSlot
    bool isShiftTime = shifts != null && shifts.any((shift) {
      int startHour = _parseHour(shift['start']!);
      int endHour = _parseHour(shift['end']!);
      return timeSlotHour >= startHour && timeSlotHour < endHour; // Check if within the shift time
    });

    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: isShiftTime ? Colors.green : Colors.white,
      ),
      child: Center(
        child: isShiftTime
            ? Text(shifts!.firstWhere((shift) => _parseHour(shift['start']!) <= timeSlotHour && timeSlotHour < _parseHour(shift['end']!))['room']!, textAlign: TextAlign.center)
            : Text('', textAlign: TextAlign.center), // Return an empty string for other times
      ),
    );
  }

  // Helper function to parse hour string to 24-hour format
  int _parseHour(String hourString) {
    final parts = hourString.split(' ');
    int hour = int.parse(parts[0]);
    if (hour == 12) hour = 0; // 12 AM should be 0
    if (parts[1] == 'PM') hour += 12; // Convert PM to 24-hour format
    return hour;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<DateTime> weekDates = _getWeekDates();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Column(
          children: [
            // Year display
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${DateFormat('y').format(weekDates[0])}', // Extract the year from the start date
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousWeek,
                ),
                Text(
                  '${DateFormat('MMM d').format(weekDates[0])} - ${DateFormat('MMM d').format(weekDates[6])}', // Display current week range
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _nextWeek,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FixedColumnWidth(50), // Fixed width for time column
                  },
                  children: [
                    // Header row with days of the week
                    TableRow(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          height: 70,
                          child: Center(
                            child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),
                        ...weekDates.asMap().entries.map((entry) {
                          int index = entry.key;
                          DateTime date = entry.value;
                          String formattedDate = DateFormat('MMM d').format(date);
                          bool isToday = DateTime.now().isSameDay(date);
                          return Container(
                            color: isToday ? const Color.fromARGB(255, 68, 255, 124).withOpacity(0.2) : Colors.grey[300],
                            height: 70,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(daysOfWeek[index], style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? AppColors.mainColor : Colors.black)),
                                  Text(formattedDate, style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? AppColors.mainColor : Colors.black)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    // Time slots with shifts (per hour)
                    ...List.generate(24, (hour) {
                      String period = hour < 12 ? 'AM' : 'PM';
                      int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
                      String timeSlot = '$displayHour $period'; // Create time slot string
                      
                      return TableRow(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            height: 100,
                            child: Center(
                              child: Text(timeSlot, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ),
                          ...List.generate(7, (index) {
                            DateTime date = weekDates[index];
                            return _buildShiftCell(date, timeSlot); // Pass the timeSlot to the method
                          }),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to compare dates easily
extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}
