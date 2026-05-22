class PrivateSession {
  final String id;
  final String coachId;
  final String? clientId;
  final String? clientName;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'available', 'booked', 'completed', 'cancelled'
  final int durationMinutes;
  final String? notes;

  PrivateSession({
    required this.id,
    required this.coachId,
    this.clientId,
    this.clientName,
    required this.startTime,
    required this.endTime,
    this.status = 'available',
    required this.durationMinutes,
    this.notes,
  });

  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
  
  String get timeSlot => '${_formatHour(startTime)} - ${_formatHour(endTime)}';
  String get dateFormatted => '${startTime.day}/${startTime.month}/${startTime.year}';
  
  String _formatHour(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'coachId': coachId,
    'clientId': clientId,
    'clientName': clientName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'status': status,
    'durationMinutes': durationMinutes,
    'notes': notes,
  };

  factory PrivateSession.fromJson(Map<String, dynamic> json) => PrivateSession(
    id: json['id'],
    coachId: json['coachId'],
    clientId: json['clientId'],
    clientName: json['clientName'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    status: json['status'] ?? 'available',
    durationMinutes: json['durationMinutes'] ?? 60,
    notes: json['notes'],
  );
}
