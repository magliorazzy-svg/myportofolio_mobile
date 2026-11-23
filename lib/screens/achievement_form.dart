import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Form for entering a new achievement.
///
/// The fields and rules mirror the `Achievement` model of my Django portfolio:
/// title and event (text, at most 255 characters), category (academic or
/// non-academic), description (text) and year (whole number, 1900 to 2100).
class AchievementFormPage extends StatefulWidget {
  const AchievementFormPage({super.key});

  @override
  State<AchievementFormPage> createState() => _AchievementFormPageState();
}

class _AchievementFormPageState extends State<AchievementFormPage> {
  // Rules taken from the Django model and serializer.
  static const int _maxTextLength = 255;
  static const int _minYear = 1900;
  static const int _maxYear = 2100;

  // Gives access to the form's state (validate, reset).
  final _formKey = GlobalKey<FormState>();

  // Values typed by the user, updated on every change.
  String _title = "";
  String _event = "";
  String _category = "academic"; // default
  String _description = "";
  String _year = "";

  // Stored value -> label shown to the user.
  final Map<String, String> _categories = {
    'academic': 'Academic',
    'non-academic': 'Non-Academic',
  };

  /// Shared rule for the text fields: required (not only spaces), at most 255
  /// characters, and no HTML tags (the Django form strips them with strip_tags).
  String? _validateText(String? value, String label) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) {
      return "Enter the $label.";
    }
    if (text.length > _maxTextLength) {
      return "The $label must be at most $_maxTextLength characters.";
    }
    if (text.contains('<') || text.contains('>')) {
      return "The $label must not contain HTML tags.";
    }
    return null;
  }

  String? _validateYear(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) {
      return "Enter the year.";
    }
    final year = int.tryParse(text);
    if (year == null) {
      return "The year must be a whole number.";
    }
    if (year < _minYear || year > _maxYear) {
      return "The year must be between $_minYear and $_maxYear.";
    }
    return null;
  }

  /// Clears the fields and the values stored from them.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _title = "";
      _event = "";
      _category = "academic";
      _description = "";
      _year = "";
    });
  }

  /// Shows every entered value once the form passed validation.
  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Achievement added successfully!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${_title.trim()}'),
                Text('Event: ${_event.trim()}'),
                Text('Category: ${_categories[_category]}'),
                Text('Description: ${_description.trim()}'),
                Text('Year: ${_year.trim()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Close the dialog and go back to an empty form.
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Achievement Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // Show the error next to a field as soon as the user has touched it.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // Scrolls, so every field and the Save button stay reachable on a
        // narrow screen or when the keyboard takes up space.
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          // Extra room at the bottom so Save can be scrolled above the
          // SnackBar that the action card shows when it opens this page.
          padding: const EdgeInsets.only(bottom: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Gold Medalist of Math Competition",
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) => _validateText(value, "title"),
                ),
              ),

              // === Event ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "ONSB 2025",
                    labelText: "Event",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _event = value!;
                    });
                  },
                  validator: (String? value) => _validateText(value, "event"),
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: _categories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Describe what you achieved",
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: (String? value) =>
                      _validateText(value, "description"),
                ),
              ),

              // === Year ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  // The number keyboard and digitsOnly help the user, but only
                  // the validator guarantees a valid range.
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "2025",
                    labelText: "Year",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _year = value!;
                    });
                  },
                  validator: _validateYear,
                ),
              ),

              // === Save Button ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: () {
                      // Runs every field's validator; only continue if all pass.
                      if (_formKey.currentState!.validate()) {
                        _showSummary();
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
