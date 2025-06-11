class Log {
  final int id;
  final String sessionId;
  final String? userId;
  final DateTime createdAt;
  final String? device;
  final Map<String, String> actions;

  Log({
    required this.id,
    required this.sessionId,
    this.userId,
    required this.createdAt,
    this.device,
    required this.actions,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    final baseDate = DateTime.parse(json['created_at'] as String);
    final actions = json['actions'] != null 
        ? Map<String, String>.from(json['actions'] as Map)
        : <String, String>{};
    
    // If there are actions, use the time from the first action
    DateTime finalDate = baseDate;
    if (actions.isNotEmpty) {
      final firstActionTime = actions.keys.first;
      final timeParts = firstActionTime.split(':');
      if (timeParts.length == 3) {
        finalDate = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
        );
      }
    }

    return Log(
      id: json['id'] as int,
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String?,
      createdAt: finalDate,
      device: json['device'] as String?,
      actions: actions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'device': device,
      'actions': actions,
    };
  }

  @override
  String toString() {
    return 'Log(id: $id, sessionId: $sessionId, userId: $userId, createdAt: $createdAt, device: $device, actions: $actions)';
  }
} 