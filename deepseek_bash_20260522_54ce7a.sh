# Créer les dossiers manquants
mkdir -p lib/core/theme lib/core/utils lib/core/models lib/features/auth lib/features/client lib/features/coach lib/services

# ============ FICHIER 1 : lib/main.dart ============
cat > lib/main.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  await apiService.initialize();
  runApp(
    Provider<ApiService>.value(
      value: apiService,
      child: const CoachApp(),
    ),
  );
}
ENDOFFILE

# ============ FICHIER 2 : lib/app.dart ============
cat > lib/app.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';

class CoachApp extends StatelessWidget {
  const CoachApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coach App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
ENDOFFILE

# ============ FICHIER 3 : lib/core/theme/app_theme.dart ============
cat > lib/core/theme/app_theme.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color accentColor = Color(0xFF00F2A9);
  static const Color backgroundColor = Color(0xFF0A0E21);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color cardColor = Color(0xFF16213E);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
    cardTheme: CardTheme(color: cardColor, elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      prefixIconColor: Colors.white54, labelStyle: const TextStyle(color: Colors.white54),
    ),
  );
}
ENDOFFILE

# ============ FICHIER 4 : lib/core/models/user_model.dart ============
cat > lib/core/models/user_model.dart << 'ENDOFFILE'
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final double? bodyFatPercentage;
  final double? waistCm;
  final double? hipCm;
  final String? experienceLevel;
  final String? jobType;
  final String? primaryGoal;
  final int? workoutsPerWeek;
  final List<String>? workoutTypes;
  final Map<String, dynamic>? metabolicProfile;

  UserModel({
    required this.id, required this.email, required this.firstName,
    required this.lastName, required this.role, this.gender,
    this.heightCm, this.currentWeightKg, this.bodyFatPercentage,
    this.waistCm, this.hipCm, this.experienceLevel, this.jobType,
    this.primaryGoal, this.workoutsPerWeek, this.workoutTypes,
    this.metabolicProfile,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'firstName': firstName,
    'lastName': lastName, 'role': role, 'gender': gender,
    'heightCm': heightCm, 'currentWeightKg': currentWeightKg,
    'bodyFatPercentage': bodyFatPercentage, 'waistCm': waistCm,
    'hipCm': hipCm, 'experienceLevel': experienceLevel,
    'jobType': jobType, 'primaryGoal': primaryGoal,
    'workoutsPerWeek': workoutsPerWeek, 'workoutTypes': workoutTypes,
    'metabolicProfile': metabolicProfile,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'], email: json['email'], firstName: json['firstName'],
    lastName: json['lastName'], role: json['role'], gender: json['gender'],
    heightCm: json['heightCm']?.toDouble(),
    currentWeightKg: json['currentWeightKg']?.toDouble(),
    bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
    waistCm: json['waistCm']?.toDouble(), hipCm: json['hipCm']?.toDouble(),
    experienceLevel: json['experienceLevel'], jobType: json['jobType'],
    primaryGoal: json['primaryGoal'], workoutsPerWeek: json['workoutsPerWeek'],
    workoutTypes: json['workoutTypes'] != null ? List<String>.from(json['workoutTypes']) : null,
    metabolicProfile: json['metabolicProfile'] != null ? Map<String, dynamic>.from(json['metabolicProfile']) : null,
  );
}
ENDOFFILE

# ============ FICHIER 5 : lib/core/models/class_model.dart ============
cat > lib/core/models/class_model.dart << 'ENDOFFILE'
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
    return days[dayOfWeek];
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
ENDOFFILE

# ============ FICHIER 6 : lib/core/utils/metabolic_calculator.dart ============
cat > lib/core/utils/metabolic_calculator.dart << 'ENDOFFILE'
class MetabolicProfile {
  final double bmr;
  final double tdee;
  final int targetCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final double waterIntakeLiters;
  final String bodyType;

  MetabolicProfile({
    required this.bmr, required this.tdee, required this.targetCalories,
    required this.proteinGrams, required this.carbsGrams,
    required this.fatGrams, required this.waterIntakeLiters,
    required this.bodyType,
  });

  Map<String, dynamic> toJson() => {
    'bmr': bmr, 'tdee': tdee, 'targetCalories': targetCalories,
    'proteinGrams': proteinGrams, 'carbsGrams': carbsGrams,
    'fatGrams': fatGrams, 'waterIntakeLiters': waterIntakeLiters,
    'bodyType': bodyType,
  };
}

class MetabolicCalculator {
  static MetabolicProfile calculateFullProfile({
    required String gender, required int age,
    required double weightKg, required double heightCm,
    required String experienceLevel, required double bodyFatPercentage,
    required String jobType, required int workoutsPerWeek,
    required List<String> workoutTypes, required double waistCm,
    required double hipCm, required String goal,
  }) {
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    if (bodyFatPercentage > 0) {
      double leanMass = weightKg * (1 - bodyFatPercentage / 100);
      double katchBmr = 370 + (21.6 * leanMass);
      bmr = (bmr * 0.4 + katchBmr * 0.6);
    }

    double pal = 1.2;
    Map<String, double> jobPAL = {
      'sedentary': 0.0, 'standing': 0.15,
      'light_manual': 0.25, 'heavy_manual': 0.4,
    };
    pal += jobPAL[jobType] ?? 0.0;

    Map<String, double> workoutIntensity = {
      'HIIT': 0.1, 'step': 0.08, 'sculpt': 0.07, 'private': 0.09,
    };
    double weeklyPAL = 0;
    for (String type in workoutTypes) {
      weeklyPAL += workoutIntensity[type] ?? 0.05;
    }
    pal += weeklyPAL * (workoutsPerWeek / 7);

    Map<String, double> expFactors = {
      'beginner': 1.15, 'intermediate': 1.0,
      'advanced': 0.88, 'elite': 0.82,
    };
    double expFactor = expFactors[experienceLevel] ?? 1.0;

    double whr = waistCm / hipCm;
    double healthFactor = whr > 0.9 ? 0.95 : 1.0;
    double tdee = bmr * pal * expFactor * healthFactor;

    Map<String, double> goals = {
      'extreme_weight_loss': 0.75, 'moderate_weight_loss': 0.85,
      'recomposition': 0.95, 'maintenance': 1.0,
      'lean_bulk': 1.07, 'aggressive_bulk': 1.15,
    };
    int targetCal = (tdee * (goals[goal] ?? 1.0)).round();

    int proteinG = (weightKg * 2.2).round();
    int fatG = ((targetCal * 0.25) / 9).round();
    int carbG = ((targetCal - (proteinG * 4) - (fatG * 9)) / 4).round();
    double waterL = weightKg * 0.033;

    String bodyType;
    if (gender == 'male') {
      if (bodyFatPercentage < 15 && whr < 0.9) bodyType = 'Ectomorphe';
      else if (bodyFatPercentage < 25) bodyType = 'Mésomorphe';
      else bodyType = 'Endomorphe';
    } else {
      if (bodyFatPercentage < 23 && whr < 0.8) bodyType = 'Ectomorphe';
      else if (bodyFatPercentage < 33) bodyType = 'Mésomorphe';
      else bodyType = 'Endomorphe';
    }

    return MetabolicProfile(
      bmr: bmr, tdee: tdee, targetCalories: targetCal,
      proteinGrams: proteinG, carbsGrams: carbG, fatGrams: fatG,
      waterIntakeLiters: waterL, bodyType: bodyType,
    );
  }
}
ENDOFFILE

# ============ FICHIER 7 : lib/services/api_service.dart ============
cat > lib/services/api_service.dart << 'ENDOFFILE'
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';
import '../core/models/class_model.dart';

class ApiService {
  late SharedPreferences _prefs;
  List<UserModel> _users = [];
  List<GroupClass> _classes = [];
  Map<String, List<String>> _bookings = {};

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final usersJson = _prefs.getString('users');
    if (usersJson != null) {
      final List<dynamic> list = json.decode(usersJson);
      _users = list.map((u) => UserModel.fromJson(u)).toList();
    }

    final classesJson = _prefs.getString('classes');
    if (classesJson != null) {
      final List<dynamic> list = json.decode(classesJson);
      _classes = list.map((c) => GroupClass.fromJson(c)).toList();
    } else {
      _classes = [
        GroupClass(id: 'class_1', name: 'HIIT Intense', type: 'HIIT',
          dayOfWeek: 1, startTime: '18:00', endTime: '19:00',
          maxCapacity: 15, currentBookings: 8),
        GroupClass(id: 'class_2', name: 'Sculpt in Music', type: 'sculpt_in_music',
          dayOfWeek: 6, startTime: '10:00', endTime: '11:00',
          maxCapacity: 15, currentBookings: 12),
        GroupClass(id: 'class_3', name: 'Iron Step', type: 'iron_step',
          dayOfWeek: 7, startTime: '10:00', endTime: '11:00',
          maxCapacity: 15, currentBookings: 5),
      ];
      await _saveClasses();
    }

    final bookingsJson = _prefs.getString('bookings');
    if (bookingsJson != null) {
      final Map<String, dynamic> map = json.decode(bookingsJson);
      _bookings = map.map((k, v) => MapEntry(k, List<String>.from(v)));
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (e) {
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email, firstName: 'Coachée', lastName: 'Test',
        role: 'client',
      );
      _users.add(user);
      await _saveUsers();
      return user;
    }
  }

  Future<List<GroupClass>> getClasses() async => _classes;

  Future<bool> bookClass(String userId, String classId) async {
    final i = _classes.indexWhere((c) => c.id == classId);
    if (i == -1 || _classes[i].isFull) return false;
    if (_bookings[userId]?.contains(classId) == true) return false;

    _bookings.putIfAbsent(userId, () => []).add(classId);
    final c = _classes[i];
    _classes[i] = GroupClass(id: c.id, name: c.name, type: c.type,
      dayOfWeek: c.dayOfWeek, startTime: c.startTime, endTime: c.endTime,
      maxCapacity: c.maxCapacity, currentBookings: c.currentBookings + 1);

    await _saveBookings(); await _saveClasses();
    return true;
  }

  Future<bool> cancelBooking(String userId, String classId) async {
    if (!_bookings.containsKey(userId)) return false;
    final i = _classes.indexWhere((c) => c.id == classId);
    if (i == -1) return false;

    _bookings[userId]?.remove(classId);
    final c = _classes[i];
    _classes[i] = GroupClass(id: c.id, name: c.name, type: c.type,
      dayOfWeek: c.dayOfWeek, startTime: c.startTime, endTime: c.endTime,
      maxCapacity: c.maxCapacity, currentBookings: c.currentBookings - 1);

    await _saveBookings(); await _saveClasses();
    return true;
  }

  List<GroupClass> getUserBookings(String userId) {
    if (!_bookings.containsKey(userId)) return [];
    final ids = _bookings[userId]!;
    return _classes.where((c) => ids.contains(c.id)).toList();
  }

  Future<void> updateUserProfile(UserModel user) async {
    final i = _users.indexWhere((u) => u.id == user.id);
    if (i != -1) { _users[i] = user; } else { _users.add(user); }
    await _saveUsers();
  }

  Future<void> _saveUsers() async {
    await _prefs.setString('users', json.encode(_users.map((u) => u.toJson()).toList()));
  }

  Future<void> _saveClasses() async {
    await _prefs.setString('classes', json.encode(_classes.map((c) => c.toJson()).toList()));
  }

  Future<void> _saveBookings() async {
    await _prefs.setString('bookings', json.encode(_bookings));
  }
}
ENDOFFILE

# ============ FICHIER 8 : lib/features/auth/login_screen.dart ============
cat > lib/features/auth/login_screen.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../client/client_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final api = context.read<ApiService>();
      final user = await api.login(_emailCtrl.text, _passCtrl.text);
      if (mounted) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ClientDashboard(user: user)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.backgroundColor, AppTheme.surfaceColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(Icons.fitness_center, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 35),
                  const Text('COACH APP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Votre partenaire fitness', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 45),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock_outlined)),
                    obscureText: true,
                    validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(width: double.infinity, height: 52,
                    child: ElevatedButton(onPressed: _login, child: const Text('SE CONNECTER')),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () { _emailCtrl.text = 'demo@coach.com'; _passCtrl.text = '123456'; _login(); },
                    child: const Text('Accès rapide (démo)', style: TextStyle(color: Colors.white38)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
ENDOFFILE

# ============ FICHIER 9 : lib/features/client/client_dashboard.dart ============
cat > lib/features/client/client_dashboard.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/metabolic_calculator.dart';
import '../../services/api_service.dart';
import 'profile_setup_screen.dart';
import 'booking_screen.dart';

class ClientDashboard extends StatefulWidget {
  final UserModel user;
  const ClientDashboard({super.key, required this.user});
  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;
  late UserModel _user;
  MetabolicProfile? _meta;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadMeta();
  }

  void _loadMeta() {
    if (_user.metabolicProfile != null) {
      final m = _user.metabolicProfile!;
      _meta = MetabolicProfile(
        bmr: m['bmr'], tdee: m['tdee'], targetCalories: m['targetCalories'],
        proteinGrams: m['proteinGrams'], carbsGrams: m['carbsGrams'],
        fatGrams: m['fatGrams'], waterIntakeLiters: m['waterIntakeLiters'],
        bodyType: m['bodyType'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildHome(), const BookingScreen(), _buildProfile()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Cours'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 28, backgroundColor: AppTheme.primaryColor,
              child: Text(_user.firstName[0].toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(width: 14),
            Text('Bonjour, ${_user.firstName}', style: Theme.of(context).textTheme.headlineMedium),
          ]),
          const SizedBox(height: 28),
          if (_meta != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.8), AppTheme.secondaryColor.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('VOTRE MÉTABOLISME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Text(_meta!.bodyType, style: const TextStyle(color: Colors.white, fontSize: 12))),
                ]),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _stat('BMR', '${_meta!.bmr.round()}', 'kcal'),
                  _stat('TDEE', '${_meta!.tdee.round()}', 'kcal'),
                  _stat('Objectif', '${_meta!.targetCalories}', 'kcal'),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MACROS QUOTIDIENS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _macro('Protéines', '${_meta!.proteinGrams}g', AppTheme.secondaryColor),
                  _macro('Glucides', '${_meta!.carbsGrams}g', Colors.orange),
                  _macro('Lipides', '${_meta!.fatGrams}g', Colors.blue),
                ]),
                const SizedBox(height: 12),
                Center(child: Text('💧 ${_meta!.waterIntakeLiters.toStringAsFixed(1)}L d\'eau/jour',
                  style: const TextStyle(color: Colors.blue, fontSize: 13))),
              ])),
            ),
          ] else ...[
            Card(
              child: Padding(padding: const EdgeInsets.all(30), child: Column(children: [
                const Icon(Icons.fitness_center, size: 50, color: AppTheme.primaryColor),
                const SizedBox(height: 12),
                const Text('Complétez votre profil', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Pour obtenir votre analyse métabolique', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 18),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: _user)));
                      if (result != null && mounted) {
                        setState(() { _user = result; _loadMeta(); });
                      }
                    },
                    child: const Text('CONFIGURER MON PROFIL'),
                  ),
                ),
              ])),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stat(String label, String val, String unit) {
    return Column(children: [
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
      Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _macro(String label, String val, Color color) {
    return Column(children: [
      Text(val, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
    ]);
  }

  Widget _buildProfile() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.person, size: 70, color: Colors.white24),
      const SizedBox(height: 18),
      Text(_user.firstName, style: const TextStyle(fontSize: 22, color: Colors.white)),
      const SizedBox(height: 18),
      ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: _user)));
          if (result != null && mounted) setState(() { _user = result; _loadMeta(); });
        },
        child: const Text('MODIFIER MON PROFIL'),
      ),
    ]));
  }
}
ENDOFFILE

# ============ FICHIER 10 : lib/features/client/profile_setup_screen.dart ============
cat > lib/features/client/profile_setup_screen.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/metabolic_calculator.dart';
import '../../services/api_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel user;
  const ProfileSetupScreen({super.key, required this.user});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _user;
  late TextEditingController _heightCtrl, _weightCtrl, _bodyFatCtrl, _waistCtrl, _hipCtrl;
  String _gender = 'female', _experienceLevel = 'beginner', _jobType = 'sedentary', _primaryGoal = 'moderate_weight_loss';
  int _workoutsPerWeek = 3;
  List<String> _workoutTypes = [];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _heightCtrl = TextEditingController(text: _user.heightCm?.toString() ?? '');
    _weightCtrl = TextEditingController(text: _user.currentWeightKg?.toString() ?? '');
    _bodyFatCtrl = TextEditingController(text: _user.bodyFatPercentage?.toString() ?? '');
    _waistCtrl = TextEditingController(text: _user.waistCm?.toString() ?? '');
    _hipCtrl = TextEditingController(text: _user.hipCm?.toString() ?? '');
    _gender = _user.gender ?? 'female';
    _experienceLevel = _user.experienceLevel ?? 'beginner';
    _jobType = _user.jobType ?? 'sedentary';
    _primaryGoal = _user.primaryGoal ?? 'moderate_weight_loss';
    _workoutsPerWeek = _user.workoutsPerWeek ?? 3;
    _workoutTypes = _user.workoutTypes ?? [];
  }

  @override
  void dispose() {
    _heightCtrl.dispose(); _weightCtrl.dispose(); _bodyFatCtrl.dispose();
    _waistCtrl.dispose(); _hipCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final h = double.parse(_heightCtrl.text);
      final w = double.parse(_weightCtrl.text);
      final bf = double.tryParse(_bodyFatCtrl.text) ?? 0;
      final waist = double.tryParse(_waistCtrl.text) ?? 70;
      final hip = double.tryParse(_hipCtrl.text) ?? 90;
      final age = 30;

      final meta = MetabolicCalculator.calculateFullProfile(
        gender: _gender, age: age, weightKg: w, heightCm: h,
        experienceLevel: _experienceLevel, bodyFatPercentage: bf,
        jobType: _jobType, workoutsPerWeek: _workoutsPerWeek,
        workoutTypes: _workoutTypes, waistCm: waist, hipCm: hip,
        goal: _primaryGoal,
      );

      final updated = UserModel(
        id: _user.id, email: _user.email, firstName: _user.firstName,
        lastName: _user.lastName, role: _user.role,
        gender: _gender, heightCm: h, currentWeightKg: w,
        bodyFatPercentage: bf, waistCm: waist, hipCm: hip,
        experienceLevel: _experienceLevel, jobType: _jobType,
        primaryGoal: _primaryGoal, workoutsPerWeek: _workoutsPerWeek,
        workoutTypes: _workoutTypes, metabolicProfile: meta.toJson(),
      );

      await context.read<ApiService>().updateUserProfile(updated);
      if (mounted) Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL COACHING')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('GENRE', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _gender = 'female'),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: _gender == 'female' ? AppTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gender == 'female' ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3))),
                  child: const Column(children: [Text('👩', style: TextStyle(fontSize: 30)), Text('Femme')])),
              )),
              const SizedBox(width: 15),
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _gender = 'male'),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: _gender == 'male' ? AppTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gender == 'male' ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3))),
                  child: const Column(children: [Text('👨', style: TextStyle(fontSize: 30)), Text('Homme')])),
              )),
            ]),
            const SizedBox(height: 25),
            const Text('MESURES', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(controller: _heightCtrl, decoration: const InputDecoration(labelText: 'Taille (cm)'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Requis' : null)),
              const SizedBox(width: 15),
              Expanded(child: TextFormField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Poids (kg)'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Requis' : null)),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: TextFormField(controller: _waistCtrl, decoration: const InputDecoration(labelText: 'Tour taille (cm)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 15),
              Expanded(child: TextFormField(controller: _hipCtrl, decoration: const InputDecoration(labelText: 'Tour hanches (cm)'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 15),
            TextFormField(controller: _bodyFatCtrl, decoration: const InputDecoration(labelText: '% Masse grasse (optionnel)'), keyboardType: TextInputType.number),
            const SizedBox(height: 25),
            const Text('EXPÉRIENCE', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(spacing: 10, children: ['beginner','intermediate','advanced','elite'].map((e) => ChoiceChip(
              label: Text({'beginner':'Débutant','intermediate':'Intermédiaire','advanced':'Avancé','elite':'Élite'}[e]!),
              selected: _experienceLevel == e,
              onSelected: (_) => setState(() => _experienceLevel = e),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(color: _experienceLevel == e ? Colors.white : null),
            )).toList()),
            const SizedBox(height: 25),
            const Text('OBJECTIF', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(spacing: 10, children: [
              'extreme_weight_loss','moderate_weight_loss','recomposition','maintenance','lean_bulk','aggressive_bulk'
            ].map((g) => ChoiceChip(
              label: Text({'extreme_weight_loss':'Perte extrême','moderate_weight_loss':'Perte modérée','recomposition':'Recomposition','maintenance':'Maintien','lean_bulk':'Masse légère','aggressive_bulk':'Masse'}[g]!, style: const TextStyle(fontSize: 12)),
              selected: _primaryGoal == g,
              onSelected: (_) => setState(() => _primaryGoal = g),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(color: _primaryGoal == g ? Colors.white : null),
            )).toList()),
            const SizedBox(height: 25),
            const Text('FRÉQUENCE', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13)),
            Text('Séances par semaine : $_workoutsPerWeek'),
            Slider(value: _workoutsPerWeek.toDouble(), min: 1, max: 7, divisions: 6, activeColor: AppTheme.primaryColor, onChanged: (v) => setState(() => _workoutsPerWeek = v.round())),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                child: const Text('CALCULER MON MÉTABOLISME', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
            ),
          ]),
        ),
      ),
    );
  }
}
ENDOFFILE

# ============ FICHIER 11 : lib/features/client/booking_screen.dart ============
cat > lib/features/client/booking_screen.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/class_model.dart';
import '../../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<GroupClass> _classes = [];
  List<GroupClass> _userBookings = [];
  bool _isLoading = true;
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final api = context.read<ApiService>();
    final classes = await api.getClasses();
    final bookings = api.getUserBookings('default_user');
    setState(() { _classes = classes; _userBookings = bookings; _isLoading = false; });
  }

  Future<void> _book(GroupClass c) async {
    final ok = await context.read<ApiService>().bookClass('default_user', c.id);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Réservé : ${c.name}'), backgroundColor: AppTheme.accentColor)); _load(); }
  }

  Future<void> _cancel(GroupClass c) async {
    final ok = await context.read<ApiService>().cancelBooking('default_user', c.id);
    if (ok && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Annulé'))); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    final items = _tab == 'my' ? _userBookings : _classes;
    return Scaffold(
      appBar: AppBar(title: const Text('RÉSERVATIONS'), bottom: PreferredSize(preferredSize: const Size.fromHeight(50), child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(children: [
          Expanded(child: GestureDetector(onTap: () => setState(() => _tab = 'all'), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: _tab == 'all' ? AppTheme.primaryColor : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('COURS', style: TextStyle(fontWeight: FontWeight.w600)))))),
          const SizedBox(width: 10),
          Expanded(child: GestureDetector(onTap: () => setState(() => _tab = 'my'), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: _tab == 'my' ? AppTheme.primaryColor : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text('MES RÉSAS (${_userBookings.length})', style: const TextStyle(fontWeight: FontWeight.w600)))))),
        ]),
      ))),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : items.isEmpty ? const Center(child: Text('Aucun cours', style: TextStyle(color: Colors.grey))) : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final c = items[i];
          final booked = _userBookings.any((b) => b.id == c.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(c.iconName, style: const TextStyle(fontSize: 24)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('${c.dayName}  ${c.startTime}-${c.endTime}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ])),
              ]),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: c.currentBookings / c.maxCapacity, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(c.isFull ? Colors.red : AppTheme.accentColor), minHeight: 6),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${c.remainingSpots} places', style: TextStyle(color: c.isFull ? Colors.red : AppTheme.accentColor, fontWeight: FontWeight.w600, fontSize: 12)),
                booked ? TextButton(onPressed: () => _cancel(c), child: const Text('ANNULER', style: TextStyle(color: Colors.red))) : ElevatedButton(onPressed: c.isFull ? null : () => _book(c), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)), child: Text(c.isFull ? 'COMPLET' : 'RÉSERVER', style: const TextStyle(fontSize: 12))),
              ]),
            ])),
          );
        },
      ),
    );
  }
}
ENDOFFILE

# ============ FICHIER 12 : lib/features/coach/coach_dashboard.dart ============
cat > lib/features/coach/coach_dashboard.dart << 'ENDOFFILE'
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ESPACE COACH')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _statCard('Clients', '24', Icons.people, AppTheme.primaryColor)),
            const SizedBox(width: 15),
            Expanded(child: _statCard('Aujourd\'hui', '3', Icons.fitness_center, AppTheme.accentColor)),
          ]),
          const SizedBox(height: 30),
          const Text('PLANNING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          const SizedBox(height: 15),
          _sessionCard('HIIT Intense', '18:00 - 19:00', '8/15', AppTheme.secondaryColor),
          const SizedBox(height: 10),
          _sessionCard('Sculpt in Music', '10:00 - 11:00', '12/15', Colors.purple),
          const SizedBox(height: 10),
          _sessionCard('Iron Step', '10:00 - 11:00', '5/15', Colors.orange),
        ]),
      ),
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color), const SizedBox(height: 10),
        Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }

  Widget _sessionCard(String title, String time, String status, Color color) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
        Container(width: 4, height: 50, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12))),
      ])),
    );
  }
}
ENDOFFILE

echo ""
echo "=========================================="
echo " ✅ TOUS LES FICHIERS SONT CRÉÉS !"
echo "=========================================="
echo ""
echo "Lance l'application avec :"
echo "  cd ~/Bureau/coach_app"
echo "  flutter run -d linux"
echo ""