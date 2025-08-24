enum ProjectStatus { onTrack, delayed, completed, pending }

class Project {
  final String id;
  final String name;
  final String clientName;
  final double progress;
  final ProjectStatus status;
  final DateTime deadline;

  Project({
    required this.id,
    required this.name,
    required this.clientName,
    required this.progress,
    required this.status,
    required this.deadline,
  });
}
