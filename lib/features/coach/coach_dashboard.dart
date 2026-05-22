import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/models/class_model.dart';
import '../../services/api_service.dart';
import '../auth/welcome_screen.dart';
import 'session_manager_screen.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});
  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  int _currentTab = 0;

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deconnexion', style: TextStyle(color: Colors.white)),
        content: const Text('Voulez-vous vraiment vous deconnecter ?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
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
      appBar: AppBar(
        title: const Text('ESPACE COACH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'Gerer les creneaux',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionManagerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.secondaryColor),
            tooltip: 'Deconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [_buildOverview(), _buildPendingUsers(), _buildClientsList(), _buildReservations()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Vue ensemble'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Validations'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Coaches'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Reservations'),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final api = context.watch<ApiService>();
    final pendingCount = api.getPendingUsers().length;
    final clientsCount = api.getValidatedClients().length;
    final classes = api.getClasses();
    final sessions = api.getSessions();
    final bookedSessions = sessions.where((s) => s.isBooked).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bonjour Coach ! 👋', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 25),
        Row(children: [
          Expanded(child: _statCard('Coaches', '$clientsCount', Icons.people, AppTheme.primaryColor)),
          const SizedBox(width: 15),
          Expanded(child: _statCard('En attente', '$pendingCount', Icons.hourglass_bottom, Colors.orange)),
        ]),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: _statCard('Cours/sem', '${classes.length}', Icons.fitness_center, AppTheme.accentColor)),
          const SizedBox(width: 15),
          Expanded(child: _statCard('Prives', '$bookedSessions', Icons.lock, Colors.purple)),
        ]),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionManagerScreen())),
            icon: const Icon(Icons.edit_calendar, color: AppTheme.primaryColor),
            label: const Text('GERER LES CRENEAUX PRIVES', style: TextStyle(color: AppTheme.primaryColor)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), side: const BorderSide(color: AppTheme.primaryColor)),
          ),
        ),
        const SizedBox(height: 25),
        const Text('COURS DE LA SEMAINE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
        const SizedBox(height: 15),
        ...classes.map((c) => _classCard(c, api)),
        const SizedBox(height: 20),
        // Bouton deconnexion en bas
        Center(
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppTheme.secondaryColor),
            label: const Text('SE DECONNECTER', style: TextStyle(color: AppTheme.secondaryColor)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.secondaryColor), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildPendingUsers() {
    final api = context.watch<ApiService>();
    final pending = api.getPendingUsers();
    if (pending.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.check_circle, size: 70, color: AppTheme.accentColor),
        SizedBox(height: 20),
        Text('Aucune inscription en attente', style: TextStyle(fontSize: 18, color: Colors.white54)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pending.length,
      itemBuilder: (_, i) {
        final user = pending[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(children: [
              CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.2), child: Text(user.firstName[0].toUpperCase(), style: const TextStyle(color: Colors.orange))),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
              IconButton(icon: const Icon(Icons.check_circle, color: AppTheme.accentColor), onPressed: () { api.validateUser(user); setState(() {}); }),
              IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () { api.rejectUser(user); setState(() {}); }),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildClientsList() {
    final api = context.watch<ApiService>();
    final clients = api.getValidatedClients();
    if (clients.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline, size: 70, color: Colors.white24),
        SizedBox(height: 20),
        Text('Aucun coache pour le moment', style: TextStyle(fontSize: 18, color: Colors.white54)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: clients.length,
      itemBuilder: (_, i) {
        final client = clients[i];
        final bookings = api.getUserBookings(client.id);
        final sessions = api.getClientSessions(client.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.2), child: Text(client.firstName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor))),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${client.firstName} ${client.lastName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(client.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmDelete(client)),
              ]),
              if (bookings.isNotEmpty || sessions.isNotEmpty) ...[
                const SizedBox(height: 10),
                if (bookings.isNotEmpty) ...[
                  const Text('Cours collectifs :', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ...bookings.map((c) => Padding(padding: const EdgeInsets.only(left: 10, top: 4), child: Text('${c.iconName} ${c.name} - ${c.dayName} ${c.startTime}', style: const TextStyle(fontSize: 12)))),
                ],
                if (sessions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  const Text('Coaching prive :', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ...sessions.map((s) => Padding(padding: const EdgeInsets.only(left: 10, top: 4), child: Text('🔒 ${s.dateFormatted} ${s.timeSlot}', style: const TextStyle(fontSize: 12)))),
                ],
              ],
              if (client.metabolicProfile != null)
                Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text('📊 Profil complete', style: TextStyle(color: AppTheme.accentColor, fontSize: 11))),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildReservations() {
    final api = context.watch<ApiService>();
    final classes = api.getClasses();
    final bookingsByClass = api.getBookingsByClass();
    final sessions = api.getSessions();
    final bookedSessions = sessions.where((s) => s.isBooked).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: (bookedSessions.isNotEmpty ? 1 : 0) + classes.length,
      itemBuilder: (_, i) {
        if (bookedSessions.isNotEmpty && i == 0) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('COACHING PRIVE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.purple, letterSpacing: 1)),
            const SizedBox(height: 10),
            ...bookedSessions.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.purple.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.purple),
                title: Text(s.clientName ?? 'Inconnu', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${s.dateFormatted}  ${s.timeSlot}  ${s.durationMinutes}min'),
                trailing: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () { api.cancelSession(s.id); setState(() {}); }),
              ),
            )),
            const SizedBox(height: 25),
            const Text('COURS COLLECTIFS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor, letterSpacing: 1)),
            const SizedBox(height: 10),
          ]);
        }
        final idx = bookedSessions.isNotEmpty ? i - 1 : i;
        final c = classes[idx];
        final bookedUsers = bookingsByClass[c.id] ?? [];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(c.iconName, style: const TextStyle(fontSize: 24)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('${c.dayName} ${c.startTime}-${c.endTime}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ])),
                Text('${bookedUsers.length}/${c.maxCapacity}', style: TextStyle(color: c.isFull ? Colors.red : AppTheme.accentColor, fontWeight: FontWeight.w700, fontSize: 18)),
              ]),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: bookedUsers.length / c.maxCapacity, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(c.isFull ? Colors.red : AppTheme.accentColor), minHeight: 6),
              if (bookedUsers.isNotEmpty) ...[
                const SizedBox(height: 15),
                const Text('Participants :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white54)),
                ...bookedUsers.map((uid) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(api.getUserName(uid), style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    GestureDetector(onTap: () { api.cancelBooking(uid, c.id); setState(() {}); }, child: const Icon(Icons.close, size: 16, color: Colors.red)),
                  ]),
                )),
              ],
            ]),
          ),
        );
      },
    );
  }

  void _confirmDelete(UserModel client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
        content: Text('Supprimer ${client.firstName} ${client.lastName} ?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(onPressed: () { context.read<ApiService>().deleteClient(client.id); Navigator.pop(ctx); setState(() {}); }, child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
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

  Widget _classCard(GroupClass c, ApiService api) {
    final bookings = api.getBookingsByClass();
    final count = (bookings[c.id] ?? []).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Text(c.iconName, style: const TextStyle(fontSize: 24)),
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${c.dayName} ${c.startTime}-${c.endTime}'),
        trailing: Text('$count/${c.maxCapacity}', style: TextStyle(color: c.isFull ? Colors.red : AppTheme.accentColor, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
