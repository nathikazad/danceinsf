import 'package:dance_sf/utils/string.dart';

class Proposal {
  final int id;
  final DateTime createdAt;
  final String userId;
  final String? eventId;
  final String? eventInstanceId;
  final Map<String, dynamic> changes;
  final List<String> yeses;
  final List<String> nos;
  final bool resolved;

  Proposal({
    required this.id,
    required this.createdAt,
    required this.userId,
    this.eventId,
    this.eventInstanceId,
    required this.changes,
    this.yeses = const [],
    this.nos = const [],
    this.resolved = false,
  });

  factory Proposal.fromMap(Map<String, dynamic> map) {
    return Proposal(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
      eventId: map['event_id'] as String?,
      eventInstanceId: map['event_instance_id'] as String?,
      changes: map['changes'] as Map<String, dynamic>,
      yeses: toStringList(map['yeses']),
      nos: toStringList(map['nos']),
      resolved: map['resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'event_id': eventId,
      'event_instance_id': eventInstanceId,
      'changes': changes,
      'yeses': yeses,
      'nos': nos,
      'resolved': resolved,
    };
  }
} 