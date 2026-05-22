class GroupClass {
  final String id;
  final String name;
  final String type;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int maxCapacity;
  final int currentBookings;

  GroupClass({
    required this.id, required this.name, required this.type,
    required this.dayOfWeek, required this.startTime,
    required this.endTime, required this.maxCapacity,
    required this.currentBookings,
  });

  int get remainingSpots => maxCapacity - currentBookings;
  bool get isFull => remainingSpots <= 0;

  String get dayName {
    const days = ['Dimanche','Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'];
    // Le dimanche peut être 0 ou 7, on normalise
    final index = dayOfWeek == 7 ? 0 : dayOfWeek;
    return days[index];
  }

  String get iconName {
    switch (type) {
      case 'HIIT': return '⚡';
      case 'sculpt_in_music': return '🎵';
      case 'iron_step': return '🏋️';
      default: return '💪';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type, 'dayOfWeek': dayOfWeek,
    'startTime': startTime, 'endTime': endTime, 'maxCapacity': maxCapacity,
    'currentBookings': currentBookings,
  };

  factory GroupClass.fromJson(Map<String, dynamic> json) => GroupClass(
    id: json['id'], name: json['name'], type: json['type'],
    dayOfWeek: json['dayOfWeek'], startTime: json['startTime'],
    endTime: json['endTime'], maxCapacity: json['maxCapacity'],
    currentBookings: json['currentBookings'],
  );
}
