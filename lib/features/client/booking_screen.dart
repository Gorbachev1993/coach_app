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
