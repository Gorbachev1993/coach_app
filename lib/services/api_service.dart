import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';
import '../core/models/class_model.dart';
import '../core/models/session_model.dart';

class ApiService {
  late SharedPreferences _prefs;
  List<UserModel> _users = [];
  List<UserModel> _pendingUsers = [];
  List<GroupClass> _classes = [];
  Map<String, List<String>> _bookings = {};
  List<PrivateSession> _sessions = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Utilisateurs
    final usersJson = _prefs.getString('users');
    if (usersJson != null) {
      final List<dynamic> list = json.decode(usersJson);
      _users = list.map((u) => UserModel.fromJson(u)).toList();
    }
    
    final hasCoach = _users.any((u) => u.role == 'coach');
    if (!hasCoach) {
      _users.add(UserModel(
        id: 'coach_1', email: 'coach@test.com',
        firstName: 'Coach', lastName: 'Principal', role: 'coach',
      ));
      await _saveUsers();
    }

    // Utilisateurs en attente
    final pendingJson = _prefs.getString('pending_users');
    if (pendingJson != null) {
      final List<dynamic> list = json.decode(pendingJson);
      _pendingUsers = list.map((u) => UserModel.fromJson(u)).toList();
    }

    // Cours collectifs
    final classesJson = _prefs.getString('classes');
    if (classesJson != null) {
      final List<dynamic> list = json.decode(classesJson);
      _classes = list.map((c) => GroupClass.fromJson(c)).toList();
    } else {
      _classes = [
        GroupClass(id: 'class_1', name: "BE F'HIIT", type: 'HIIT',
          dayOfWeek: 1, startTime: '18:00', endTime: '19:00', maxCapacity: 15, currentBookings: 8),
        GroupClass(id: 'class_2', name: 'Sculpt in Music', type: 'sculpt_in_music',
          dayOfWeek: 6, startTime: '10:00', endTime: '11:00', maxCapacity: 15, currentBookings: 12),
        GroupClass(id: 'class_3', name: 'Iron Step', type: 'iron_step',
          dayOfWeek: 0, startTime: '10:00', endTime: '11:00', maxCapacity: 15, currentBookings: 5),
      ];
      await _saveClasses();
    }

    // Réservations cours collectifs
    final bookingsJson = _prefs.getString('bookings');
    if (bookingsJson != null) {
      final Map<String, dynamic> map = json.decode(bookingsJson);
      _bookings = map.map((k, v) => MapEntry(k, List<String>.from(v)));
    }

    // Créneaux privés
    final sessionsJson = _prefs.getString('sessions');
    if (sessionsJson != null) {
      final List<dynamic> list = json.decode(sessionsJson);
      _sessions = list.map((s) => PrivateSession.fromJson(s)).toList();
    }
  }

  // ===== AUTH =====
  Future<UserModel?> login(String email, String password) async {
    if (email.trim() == 'coach@test.com' && password == 'coach123') {
      try {
        return _users.firstWhere((u) => u.role == 'coach');
      } catch (e) {
        final coach = UserModel(id: 'coach_1', email: 'coach@test.com', firstName: 'Coach', lastName: 'Principal', role: 'coach');
        _users.add(coach);
        await _saveUsers();
        return coach;
      }
    }
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase() && u.role == 'client');
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> findUserByEmail(String email) async {
    try { return _users.firstWhere((u) => u.email == email); }
    catch (e) {
      try { return _pendingUsers.firstWhere((u) => u.email == email); }
      catch (e) { return null; }
    }
  }

  Future<void> registerPendingUser(UserModel user) async {
    _pendingUsers.add(user);
    await _savePendingUsers();
  }

  List<UserModel> getPendingUsers() => _pendingUsers;
  List<UserModel> getValidatedClients() => _users.where((u) => u.role == 'client').toList();
  List<GroupClass> getClasses() => _classes;

  Future<void> validateUser(UserModel user) async {
    _pendingUsers.removeWhere((u) => u.id == user.id);
    _users.add(UserModel(id: DateTime.now().millisecondsSinceEpoch.toString(), email: user.email, firstName: user.firstName, lastName: user.lastName, role: 'client'));
    await _savePendingUsers();
    await _saveUsers();
  }

  Future<void> rejectUser(UserModel user) async {
    _pendingUsers.removeWhere((u) => u.id == user.id);
    await _savePendingUsers();
  }

  Future<void> deleteClient(String userId) async {
    _users.removeWhere((u) => u.id == userId);
    _bookings.remove(userId);
    _sessions.removeWhere((s) => s.clientId == userId);
    await _saveUsers();
    await _saveBookings();
    await _saveSessions();
  }

  // ===== COURS COLLECTIFS =====
  Future<bool> bookClass(String userId, String classId) async {
    final i = _classes.indexWhere((c) => c.id == classId);
    if (i == -1 || _classes[i].isFull) return false;
    if (_bookings[userId]?.contains(classId) == true) return false;
    _bookings.putIfAbsent(userId, () => []).add(classId);
    final c = _classes[i];
    _classes[i] = GroupClass(id: c.id, name: c.name, type: c.type, dayOfWeek: c.dayOfWeek, startTime: c.startTime, endTime: c.endTime, maxCapacity: c.maxCapacity, currentBookings: c.currentBookings + 1);
    await _saveBookings(); await _saveClasses();
    return true;
  }

  Future<bool> cancelBooking(String userId, String classId) async {
    if (!_bookings.containsKey(userId)) return false;
    final i = _classes.indexWhere((c) => c.id == classId);
    if (i == -1) return false;
    _bookings[userId]?.remove(classId);
    final c = _classes[i];
    _classes[i] = GroupClass(id: c.id, name: c.name, type: c.type, dayOfWeek: c.dayOfWeek, startTime: c.startTime, endTime: c.endTime, maxCapacity: c.maxCapacity, currentBookings: c.currentBookings - 1);
    await _saveBookings(); await _saveClasses();
    return true;
  }

  List<GroupClass> getUserBookings(String userId) {
    if (!_bookings.containsKey(userId)) return [];
    return _classes.where((c) => _bookings[userId]!.contains(c.id)).toList();
  }

  Map<String, List<String>> getBookingsByClass() {
    final Map<String, List<String>> result = {};
    for (final entry in _bookings.entries) {
      for (final classId in entry.value) {
        result.putIfAbsent(classId, () => []).add(entry.key);
      }
    }
    return result;
  }

  String getUserName(String userId) {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      return '${user.firstName} ${user.lastName}';
    } catch (e) { return 'Inconnu'; }
  }

  // ===== CRÉNEAUX PRIVÉS =====
  
  // Coach crée un créneau disponible
  Future<void> createSessionSlot(DateTime start, int durationMinutes) async {
    final end = start.add(Duration(minutes: durationMinutes));
    _sessions.add(PrivateSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coachId: 'coach_1',
      startTime: start,
      endTime: end,
      durationMinutes: durationMinutes,
      status: 'available',
    ));
    await _saveSessions();
  }

  // Coach supprime un créneau
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions();
  }

  // Coaché réserve un créneau
  Future<bool> bookSession(String sessionId, String clientId, String clientName) async {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i == -1 || !_sessions[i].isAvailable) return false;
    
    _sessions[i] = PrivateSession(
      id: _sessions[i].id,
      coachId: _sessions[i].coachId,
      clientId: clientId,
      clientName: clientName,
      startTime: _sessions[i].startTime,
      endTime: _sessions[i].endTime,
      durationMinutes: _sessions[i].durationMinutes,
      status: 'booked',
    );
    await _saveSessions();
    return true;
  }

  // Coaché annule
  Future<bool> cancelSession(String sessionId) async {
    final i = _sessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    
    _sessions[i] = PrivateSession(
      id: _sessions[i].id,
      coachId: _sessions[i].coachId,
      startTime: _sessions[i].startTime,
      endTime: _sessions[i].endTime,
      durationMinutes: _sessions[i].durationMinutes,
      status: 'available',
    );
    await _saveSessions();
    return true;
  }

  // Obtenir tous les créneaux
  List<PrivateSession> getSessions() => _sessions;
  
  // Créneaux disponibles pour les coachés
  List<PrivateSession> getAvailableSessions() => _sessions.where((s) => s.isAvailable).toList();
  
  // Créneaux réservés par un client
  List<PrivateSession> getClientSessions(String clientId) => _sessions.where((s) => s.clientId == clientId).toList();
  
  // Planning du coach (tous les créneaux d'un jour)
  List<PrivateSession> getCoachDaySessions(DateTime day) {
    return _sessions.where((s) => 
      s.startTime.year == day.year && 
      s.startTime.month == day.month && 
      s.startTime.day == day.day
    ).toList();
  }

  Future<void> updateUserProfile(UserModel user) async {
    final i = _users.indexWhere((u) => u.id == user.id);
    if (i != -1) { _users[i] = user; } else { _users.add(user); }
    await _saveUsers();
  }

  // ===== SAUVEGARDE =====
  Future<void> _saveUsers() async {
    await _prefs.setString('users', json.encode(_users.map((u) => u.toJson()).toList()));
  }
  Future<void> _savePendingUsers() async {
    await _prefs.setString('pending_users', json.encode(_pendingUsers.map((u) => u.toJson()).toList()));
  }
  Future<void> _saveClasses() async {
    await _prefs.setString('classes', json.encode(_classes.map((c) => c.toJson()).toList()));
  }
  Future<void> _saveBookings() async {
    await _prefs.setString('bookings', json.encode(_bookings));
  }
  Future<void> _saveSessions() async {
    await _prefs.setString('sessions', json.encode(_sessions.map((s) => s.toJson()).toList()));
  }
}
