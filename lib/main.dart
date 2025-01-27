import 'package:flutter/material.dart';  // Flutter material design package for UI components
import 'package:intl/intl.dart';  // Package for date and time formatting
import 'package:timezone/data/latest.dart' as tz;  // Timezone package for working with time zone data
import 'package:timezone/timezone.dart' as tz;  // Timezone package for handling specific time zones

void main() {
  tz.initializeTimeZones();  // Initialize time zones so the app can use them
  runApp(ClockApp());  // Run the main widget, ClockApp
}

class ClockApp extends StatefulWidget {
  @override
  _ClockAppState createState() => _ClockAppState();  // Create the state for the ClockApp widget
}

class _ClockAppState extends State<ClockApp> {
  bool isDarkMode = false;  // Boolean flag to handle switching between dark and light modes

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Hide the debug banner
      title: 'World Clock',  // Title of the application
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),  // Set theme based on dark mode status
      home: Scaffold(
        appBar: AppBar(
          title: Text('World Clock'),  // AppBar title
          actions: [
            Switch(  // A switch to toggle between dark and light modes
              value: isDarkMode,  // Current value of dark mode
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;  // Update dark mode state when the switch is toggled
                });
              },
            ),
          ],
        ),
        body: TimezonesScreen(),  // The body of the app displays the TimezonesScreen widget
      ),
    );
  }
}

class TimezonesScreen extends StatefulWidget {
  @override
  _TimezonesScreenState createState() => _TimezonesScreenState();  // Create the state for TimezonesScreen widget
}

class _TimezonesScreenState extends State<TimezonesScreen> {
  final List<String> timezones = [
    'America/New_York',  // List of default timezones
    'Europe/London',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Asia/Kolkata',
    'Africa/Cairo',
    'Pacific/Auckland',
    'UTC',  // Include UTC in the list as a default
  ];

  // Function to show the full list of timezones with a search option
  void _showTimezoneList() {
    TextEditingController searchController = TextEditingController();  // Controller for search field
    List<String> filteredTimezones = tz.timeZoneDatabase.locations.keys.toList();  // List of all available timezones

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a Timezone'),  // Title of the dialog box
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input to filter timezones
              TextField(
                controller: searchController,
                decoration: InputDecoration(hintText: 'Search Timezone'),  // Text field to enter search query
                onChanged: (query) {
                  setState(() {
                    filteredTimezones = tz.timeZoneDatabase.locations.keys
                        .where((timezone) => timezone.toLowerCase().contains(query.toLowerCase()))  // Filter timezones based on query
                        .toList();
                  });
                },
              ),
              SizedBox(height: 10),
              // ListView to show filtered timezones
              Container(
                height: 300,  // Fixed height for the list
                width: double.maxFinite,  // List width fills the dialog
                child: ListView.builder(
                  itemCount: filteredTimezones.length,  // Number of timezones to display
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredTimezones[index]),  // Display each timezone
                      onTap: () {
                        setState(() {
                          timezones.add(filteredTimezones[index]);  // Add selected timezone to the list
                        });
                        Navigator.pop(context);  // Close the dialog
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: timezones.length,  // Number of timezones to display
        itemBuilder: (context, index) {
          return TimeZoneCard(timezone: timezones[index]);  // Display each timezone in a card
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTimezoneList,  // Open the timezone list when pressed
        child: Icon(Icons.add),  // Add icon on the button
      ),
    );
  }
}

class TimeZoneCard extends StatefulWidget {
  final String timezone;  // Timezone passed to the card

  TimeZoneCard({required this.timezone});

  @override
  _TimeZoneCardState createState() => _TimeZoneCardState();  // Create the state for the TimeZoneCard widget
}

class _TimeZoneCardState extends State<TimeZoneCard> {
  late String currentTime;  // Store the current time in the selected timezone
  late String currentDate;  // Store the current date in the selected timezone

  @override
  void initState() {
    super.initState();
    _updateTime();  // Initialize the time
    Future.delayed(Duration(seconds: 1), _updateTime);  // Update time every second
  }

  // Function to update the current time for the selected timezone
  void _updateTime() {
    setState(() {
      tz.TZDateTime now;
      if (widget.timezone == 'UTC') {
        now = tz.TZDateTime.now(tz.UTC);  // Use UTC time directly if timezone is 'UTC'
      } else {
        final location = tz.getLocation(widget.timezone);  // Get the location for other timezones
        now = tz.TZDateTime.now(location);  // Get the current time in that specific timezone
      }
      currentTime = DateFormat('hh:mm:ss a').format(now);  // Format the time in 'HH:mm:ss AM/PM' format
      currentDate = DateFormat('yyyy-MM-dd').format(now);  // Format the date in 'yyyy-MM-dd' format
    });
    Future.delayed(Duration(seconds: 1), _updateTime);  // Recur to update the time every second
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),  // Rounded corners for the card
      ),
      elevation: 4,  // Set elevation for the card to make it appear slightly raised
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),  // Horizontal and vertical margin for the card
      child: Padding(
        padding: EdgeInsets.all(16),  // Padding inside the card
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Space out the children of the row
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
              children: [
                Text(
                  widget.timezone,  // Display the timezone name
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,  // Bold style for the timezone name
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  currentTime,  // Display the current time
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],  // Grey color for the time text
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  currentDate,  // Display the current date
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],  // Grey color for the date text
                  ),
                ),
              ],
            ),
            Icon(Icons.access_time, color: Colors.blueAccent),  // Time icon
          ],
        ),
      ),
    );
  }
}
