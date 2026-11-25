import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID assigned by the server, so it is left out of the POST body.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String techStack;

  /// The API returns `null` when a project has no link, so default to ''.
  @JsonKey(defaultValue: '')
  final String projectUrl;

  /// Optional: missing or `null` in the JSON becomes ''.
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
