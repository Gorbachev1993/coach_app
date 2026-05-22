import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/metabolic_calculator.dart';
import '../../core/utils/pdf_generator.dart';
import '../../services/api_service.dart';
import '../auth/welcome_screen.dart';
import 'profile_setup_screen.dart';
import 'booking_screen.dart';
import 'private_sessions_screen.dart';

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
  int _streak = 12;

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

  Future<void> _generatePdf() async {
    try {
      final file = await CoachingPdfGenerator.generateClientReport(_user);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ PDF cree : ${file.path.split('/').last}'), backgroundColor: AppTheme.accentColor));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Erreur : $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deconnexion', style: TextStyle(color: Colors.white)),
        content: const Text('Voulez-vous vraiment vous deconnecter ?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Deconnexion', style: TextStyle(color: AppTheme.secondaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(),
          const BookingScreen(),
          PrivateSessionsScreen(userId: _user.id, userName: '${_user.firstName} ${_user.lastName}'),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Collectif'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Prive'),
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
            CircleAvatar(radius: 30, backgroundColor: AppTheme.primaryColor,
              child: Text(_user.firstName[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bonjour, ${_user.firstName} ! 👋', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Row(children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text('$_streak jours de streak !', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
            ])),
            if (_meta != null)
              IconButton(
                icon: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor)),
                onPressed: _generatePdf, tooltip: 'Generer le rapport PDF',
              ),
          ]),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.2), Colors.red.withOpacity(0.1)]), borderRadius: BorderRadius.circular(15)),
            child: const Row(children: [
              Text('💪', style: TextStyle(fontSize: 30)),
              SizedBox(width: 12),
              Expanded(child: Text('"Le seul mauvais entrainement est celui qui n\'a pas eu lieu."', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 25),
          if (_meta != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.8), AppTheme.secondaryColor.withOpacity(0.8)]), borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('VOTRE METABOLISME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(_meta!.bodyType, style: const TextStyle(color: Colors.white, fontSize: 12))),
                ]),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _stat('BMR', '${_meta!.bmr.round()}', 'kcal', Icons.local_fire_department),
                  _stat('TDEE', '${_meta!.tdee.round()}', 'kcal', Icons.trending_up),
                  _stat('Objectif', '${_meta!.targetCalories}', 'kcal', Icons.flag_rounded),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('MACROS DU JOUR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  TextButton(onPressed: _generatePdf, child: const Text('📄 PDF', style: TextStyle(fontSize: 12))),
                ]),
                const SizedBox(height: 18),
                _macroBar('🥩 Proteines', _meta!.proteinGrams, AppTheme.secondaryColor),
                const SizedBox(height: 12),
                _macroBar('🍚 Glucides', _meta!.carbsGrams, Colors.orange),
                const SizedBox(height: 12),
                _macroBar('🥑 Lipides', _meta!.fatGrams, Colors.blue),
                const SizedBox(height: 15),
                Center(child: Text('💧 ${_meta!.waterIntakeLiters.toStringAsFixed(1)}L d\'eau recommandee', style: const TextStyle(color: Colors.blue, fontSize: 13))),
              ])),
            ),
          ] else ...[
            Card(
              child: Padding(padding: const EdgeInsets.all(30), child: Column(children: [
                const Icon(Icons.fitness_center, size: 60, color: AppTheme.primaryColor),
                const SizedBox(height: 15),
                const Text('Completez votre profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Pour debloquer votre analyse metabolique\net generer votre rapport PDF', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: _user)));
                    if (result != null && mounted) { setState(() { _user = result; _loadMeta(); }); }
                  },
                  child: const Text('CONFIGURER MON PROFIL'),
                )),
              ])),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stat(String label, String val, String unit, IconData icon) {
    return Column(children: [
      Icon(icon, color: Colors.white70, size: 20), const SizedBox(height: 6),
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
      Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _macroBar(String label, int grams, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text('${grams}g', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.7, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 8)),
    ]);
  }

  Widget _buildProfile() {
    return Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(radius: 50, backgroundColor: AppTheme.primaryColor, child: Text(_user.firstName[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white))),
        const SizedBox(height: 20),
        Text(_user.firstName, style: const TextStyle(fontSize: 24, color: Colors.white)),
        const SizedBox(height: 8),
        Text(_user.email, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(user: _user)));
            if (result != null && mounted) setState(() { _user = result; _loadMeta(); });
          },
          icon: const Icon(Icons.edit),
          label: const Text('MODIFIER MON PROFIL'),
        ),
        const SizedBox(height: 15),
        if (_meta != null)
          OutlinedButton.icon(
            onPressed: _generatePdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('EXPORTER EN PDF'),
          ),
        const SizedBox(height: 40),
        // Bouton deconnexion
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: AppTheme.secondaryColor),
          label: const Text('SE DECONNECTER', style: TextStyle(color: AppTheme.secondaryColor)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.secondaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ),
      ]),
    ));
  }
}
