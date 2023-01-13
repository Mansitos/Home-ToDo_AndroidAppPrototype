import 'package:flutter/material.dart';
import 'package:home_to_do/custom_widgets/pop_up_message.dart';
import 'package:home_to_do/custom_widgets/score_selection_widget.dart';
import 'package:home_to_do/utilities/categories_utilities.dart';
import 'package:home_to_do/utilities/generic_utilities.dart';
import 'package:home_to_do/utilities/globals.dart' as globals;

class CustomIntervalDialogForm extends StatefulWidget {
  CustomIntervalDialogForm({Key? key, required this.startingDaysInterval, required this.onSelect}) : super(key: key);

  int? selectedCustomDaysInterval;
  final int startingDaysInterval;
  final intCallback onSelect;

  @override
  State<CustomIntervalDialogForm> createState() => CustomIntervalDialogFormState();
}

class CustomIntervalDialogFormState extends State<CustomIntervalDialogForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "🔃 Repeat Every ... Days",
        style: TextStyle(color: Colors.black),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: _formKey,
            child: TextFormField(
              initialValue: widget.startingDaysInterval.toString(),
              onChanged: (String? value) {
                if (_formKey.currentState!.validate()) {
                  widget.selectedCustomDaysInterval = int.parse(value!);
                }
              },
              onSaved: (String? value) {},
              maxLength: 3,
              validator: (String? value) {
                final validCharacters = RegExp(r"^[0-9]+$");
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid number!';
                } else if (!validCharacters.hasMatch(value)) {
                  return 'Please enter a valid number!';
                } else {
                  widget.selectedCustomDaysInterval = int.parse(value);
                  return null;
                }
              },
              style: const TextStyle(fontSize: 18, color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Insert every how much days to repeat...",
                labelText: "Days amount",
                labelStyle: TextStyle(fontSize: 16, color: Colors.black45),
                hintStyle: TextStyle(fontSize: 16, color: Colors.black45),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                counterStyle: TextStyle(color: Colors.black45),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor: Colors.redAccent,
                heroTag: "UndoIntervalSelection",
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: "Cancel",
                child: const Icon(Icons.cancel),
              ),
              FloatingActionButton(
                heroTag: "ConfirmSelection",
                backgroundColor: Colors.amber,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    widget.onSelect(widget.selectedCustomDaysInterval!);
                  }
                },
                tooltip: "Confirm",
                child: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
