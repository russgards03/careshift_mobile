import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({Key? key}) : super(key: key);

  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final List<Map<String, String>> leaveRecords = [
    {
      'dateFiled': 'October 15, 2024',
      'timeFiled': '10:30 AM',
      'status': 'Pending',
      'leaveType': 'Sick Leave',
      'description': 'Flu symptoms',
      'leaveStart': 'October 20, 2024',
      'leaveEnd': 'October 25, 2024',
    },
    {
      'dateFiled': 'September 20, 2024',
      'timeFiled': '03:45 PM',
      'status': 'Accepted',
      'leaveType': 'Vacation Leave',
      'description': 'Family trip',
      'leaveStart': 'September 22, 2024',
      'leaveEnd': 'September 28, 2024',
    },
    {
      'dateFiled': 'August 16, 2024',
      'timeFiled': '09:15 AM',
      'status': 'Rejected',
      'leaveType': 'Sick Leave',
      'description': 'Medical appointment',
      'leaveStart': 'August 18, 2024',
      'leaveEnd': 'August 22, 2024',
    },
  ];

  void _openAddLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddLeaveDialog(
          onSave: (String leaveType, String description, DateTime startDate, DateTime endDate) {
            final newLeaveRecord = {
              'dateFiled': DateFormat.yMMMMd().format(DateTime.now()),
              'timeFiled': DateFormat.jm().format(DateTime.now()),
              'status': 'Pending',
              'leaveType': leaveType,
              'description': description,
              'leaveStart': DateFormat.yMMMMd().format(startDate),
              'leaveEnd': DateFormat.yMMMMd().format(endDate),
            };
            setState(() {
              leaveRecords.add(newLeaveRecord);
            });
          },
        );
      },
    );
  }

  void _showLeaveDetails(BuildContext context, Map<String, String> leave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Leave Details"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Leave Type: ${leave['leaveType']}'),
                Text('Description: ${leave['description']}'),
                Text('Leave Start: ${leave['leaveStart']}'),
                Text('Leave End: ${leave['leaveEnd']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: leaveRecords.length,
          itemBuilder: (context, index) {
            final leave = leaveRecords[index];
            return InkWell(
              onTap: () => _showLeaveDetails(context, leave),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Filed: ${leave['dateFiled']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Time Filed: ${leave['timeFiled']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Status: ${leave['status']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusColor(leave['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddLeaveDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}

class AddLeaveDialog extends StatefulWidget {
  final Function(String, String, DateTime, DateTime) onSave;

  AddLeaveDialog({required this.onSave});

  @override
  _AddLeaveDialogState createState() => _AddLeaveDialogState();
}

class _AddLeaveDialogState extends State<AddLeaveDialog> {
  String? _leaveType;
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  void _pickStartDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = _leaveStartDate ?? now; // Use current date if leaveStartDate is null
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _leaveStartDate = pickedDate;
        _startDateController.text = DateFormat.yMMMMd().format(pickedDate);
      });
    }
  }

  void _pickEndDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = _leaveEndDate ?? (_leaveStartDate ?? now); // Use leaveStartDate or current date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _leaveStartDate ?? now, // Ensure start date is valid
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _leaveEndDate = pickedDate;
        _endDateController.text = DateFormat.yMMMMd().format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Leave"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _leaveType,
              hint: Text('Select Leave Type'),
              onChanged: (String? newValue) {
                setState(() {
                  _leaveType = newValue;
                });
              },
              items: <String>['Sick Leave', 'Vacation Leave', 'Casual Leave']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Leave Start Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _pickStartDate(context),
                ),
              ),
            ),
            TextField(
              controller: _endDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Leave End Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _pickEndDate(context),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_leaveType != null && _descriptionController.text.isNotEmpty && _leaveStartDate != null && _leaveEndDate != null) {
              widget.onSave(
                _leaveType!,
                _descriptionController.text,
                _leaveStartDate!,
                _leaveEndDate!,
              );
              Navigator.of(context).pop();
            } else {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill all fields')),
              );
            }
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
