import 'package:flutter/material.dart';

class TimerPickerWidget extends StatefulWidget {
  final Function(String) onTimeSelected;

  TimerPickerWidget({required this.onTimeSelected});

  @override
  _TimerPickerWidgetState createState() => _TimerPickerWidgetState();
}

class _TimerPickerWidgetState extends State<TimerPickerWidget> {
  int selectedHours = 0;
  int selectedMinutes = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Omejitev višine dialoga
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Duration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  height: 150, // Višina za ListWheelScrollView
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours Picker
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHours = index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  "$index hr",
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            },
                            childCount: 24, // Max 23 hours
                          ),
                        ),
                      ),
                      // Separator
                      Text(":", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      // Minutes Picker
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedMinutes = index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  "$index min",
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            },
                            childCount: 60, // Max 59 minutes
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    String timeResult;
                    if (selectedHours > 0 && selectedMinutes > 0) {
                      timeResult = "$selectedHours hr $selectedMinutes min";
                    } else if (selectedHours > 0) {
                      timeResult = "$selectedHours hr";
                    } else {
                      timeResult = "$selectedMinutes min";
                    }
                    widget.onTimeSelected(timeResult);
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}