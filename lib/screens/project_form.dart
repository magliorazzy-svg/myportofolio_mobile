import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form for adding a project through the Django API (requires a login).
///
/// The fields match the API's ProjectSerializer: title, description,
/// tech_stack, project_url and the optional project_image_url.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Gives access to the form's state (validate, reset).
  final _formKey = GlobalKey<FormState>();

  // Values typed by the user, updated on every change.
  String _title = "";
  String _description = "";
  String _techStack = "";
  String _projectUrl = "";
  String _projectImageUrl = "";

  bool _isSubmitting = false;

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return "Enter the $label.";
    }
    return null;
  }

  /// A link must start with http:// or https:// and have a host.
  String? _validateUrl(String? value, {required bool required}) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) {
      return required ? "Enter the project URL." : null;
    }
    final uri = Uri.tryParse(text);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return valid ? null : "Enter a valid URL starting with http:// or https://";
  }

  /// A short, friendly message for a failed request. The raw response body is
  /// not shown because it could contain a server error page.
  String _messageFor(ApiException error) {
    switch (error.statusCode) {
      case 400:
        return 'The server rejected the data (HTTP 400). Check the fields.';
      case 403:
        return 'Only the portfolio owner can add projects (HTTP 403).';
      default:
        return 'Could not add the project (HTTP ${error.statusCode}).';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);

    // Protected action: ask for a login first when the user has none.
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await api.createProject(
        Project(
          title: _title.trim(),
          description: _description.trim(),
          techStack: _techStack.trim(),
          projectUrl: _projectUrl.trim(),
          projectImageUrl: _projectImageUrl.trim(),
        ),
        token: auth.token!,
      );
      if (!mounted) return;
      _showCreated(created);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        // The token is no longer valid: sign out and ask for a login again.
        await auth.logout();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Your session expired. Please log in again.'),
            ),
          );
        if (!mounted) return;
        await ensureLoggedIn(context);
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(_messageFor(error))));
      }
    } on Exception {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not reach the server.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Confirms the project the server created (HTTP 201).
  void _showCreated(Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Project added successfully!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${project.title}'),
                Text('Description: ${project.description}'),
                Text('Tech stack: ${project.techStack}'),
                Text('Project URL: ${project.projectUrl}'),
                if (project.projectImageUrl.isNotEmpty)
                  Text('Image URL: ${project.projectImageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
                setState(() {
                  _title = "";
                  _description = "";
                  _techStack = "";
                  _projectUrl = "";
                  _projectImageUrl = "";
                });
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint ?? label,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration("Title", hint: "Portfolio Website"),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) =>
                      _validateRequired(value, "title"),
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration(
                    "Description",
                    hint: "Tell us about your project",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: (String? value) =>
                      _validateRequired(value, "description"),
                ),
              ),

              // === Tech Stack ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Tech Stack",
                    hint: "Django, Python, HTML, CSS",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _techStack = value!;
                    });
                  },
                  validator: (String? value) =>
                      _validateRequired(value, "tech stack"),
                ),
              ),

              // === Project URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Project URL",
                    hint: "https://github.com/...",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _projectUrl = value!;
                    });
                  },
                  validator: (String? value) =>
                      _validateUrl(value, required: true),
                ),
              ),

              // === Project Image URL (optional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Project Image URL (optional)",
                    hint: "https://example.com/image.png",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _projectImageUrl = value!;
                    });
                  },
                  validator: (String? value) =>
                      _validateUrl(value, required: false),
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
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
