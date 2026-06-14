import 'package:flutter/material.dart';
import '../../core/database/database_service.dart';
import '../../models/glucose_log.dart';

class LogEntrySheet extends StatefulWidget {
  const LogEntrySheet({super.key});

  @override
  State<LogEntrySheet> createState() => _LogEntrySheetState();
}

class _LogEntrySheetState extends State<LogEntrySheet> {
  final glucoseController = TextEditingController();

  final insulinController = TextEditingController();

  final notesController = TextEditingController();

  bool exercised = false;

  String selectedMeal = "Before Breakfast";

  final meals = [
    "Before Breakfast",
    "After Breakfast",
    "Before Lunch",
    "After Lunch",
    "Before Dinner",
    "After Dinner",
    "Before Lantus",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),

        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 5,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            Text("Quick Log", style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 20),

            Text(DateTime.now().toString()),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedMeal,

              items: meals
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),

              onChanged: (value) {
                setState(() {
                  selectedMeal = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: glucoseController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: "Glucose Level"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: insulinController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Insulin Injected (optional)",
              ),
            ),

            const SizedBox(height: 15),

            CheckboxListTile(
              value: exercised,

              onChanged: (value) {
                setState(() {
                  exercised = value!;
                });
              },

              title: const Text("Did you exercise?"),
            ),

            TextField(
              controller: notesController,

              maxLines: 3,

              decoration: const InputDecoration(labelText: "Notes (optional)"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);

                  final log = GlucoseLog(
                    timestamp: DateTime.now(),
                    mealType: selectedMeal,
                    glucose: double.tryParse(glucoseController.text) ?? 0,

                    insulin: insulinController.text.isEmpty
                        ? null
                        : double.tryParse(insulinController.text),

                    exercised: exercised,

                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );

                  await DatabaseService.instance.insertLog(log);

                  if (!mounted) return;

                  navigator.pop();
                },
                child: const Text("SAVE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
