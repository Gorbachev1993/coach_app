import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/session_model.dart';
import '../../services/api_service.dart';

class PrivateSessionsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  const PrivateSessionsScreen({super.key, required this.userId, required this.userName});

  @override
  State<PrivateSessionsScreen> createState() => _PrivateSessionsScreenState();
}

class _PrivateSessionsScreenState extends State<PrivateSessionsScreen> {
  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();
    final availableSessions = api.getAvailableSessions();
    final mySessions = api.getClientSessions(widget.userId);

    return Scaffold(
      appBar: AppBar(title: const Text('COACHING PRIVÉ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Créneaux réservés
          if (mySessions.isNotEmpty) ...[
            const Text('MES SÉANCES RÉSERVÉES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor, letterSpacing: 1)),
            const SizedBox(height: 12),
            ...mySessions.map((s) => Card(
              color: AppTheme.accentColor.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: AppTheme.accentColor),
                title: Text(s.dateFormatted, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${s.timeSlot} (${s.durationMinutes}min)'),
                trailing: TextButton(
                  onPressed: () {
                    api.cancelSession(s.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Séance annulée'), backgroundColor: Colors.orange));
                  },
                  child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                ),
              ),
            )),
            const SizedBox(height: 25),
          ],

          // Créneaux disponibles
          const Text('CRÉNEAUX DISPONIBLES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor, letterSpacing: 1)),
          const SizedBox(height: 12),
          
          if (availableSessions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: Text('Aucun créneau disponible pour le moment.\nLa coach ajoutera des disponibilités.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54))),
              ),
            )
          else
            ...availableSessions.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.6), AppTheme.secondaryColor.withOpacity(0.6)]), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lock_open, color: Colors.white),
                ),
                title: Text(s.dateFormatted, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${s.timeSlot} • ${s.durationMinutes}min'),
                trailing: ElevatedButton(
                  onPressed: () {
                    api.bookSession(s.id, widget.userId, widget.userName);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Séance réservée le ${s.dateFormatted}'), backgroundColor: AppTheme.accentColor));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                  child: const Text('RÉSERVER', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ),
            )),
        ]),
      ),
    );
  }
}
