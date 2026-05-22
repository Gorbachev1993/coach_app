import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/session_model.dart';
import '../../services/api_service.dart';

class SessionManagerScreen extends StatefulWidget {
  const SessionManagerScreen({super.key});

  @override
  State<SessionManagerScreen> createState() => _SessionManagerScreenState();
}

class _SessionManagerScreenState extends State<SessionManagerScreen> {
  DateTime _selectedDate = DateTime.now();
  int _duration = 60; // 60 ou 120 minutes

  void _addSlot(int hour) {
    final api = context.read<ApiService>();
    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour, 0);
    api.createSessionSlot(start, _duration);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Créneau ajouté : ${hour}h - ${hour + _duration ~/ 60}h${_duration == 120 ? ' (2h)' : ''}'),
      backgroundColor: AppTheme.accentColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();
    final daySessions = api.getCoachDaySessions(_selectedDate);
    
    // Créneaux de 8h à 20h
    final hours = List.generate(13, (i) => 8 + i);

    return Scaffold(
      appBar: AppBar(title: const Text('GÉRER LES CRÉNEAUX')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Sélecteur de date
          Row(children: [
            const Text('Date :', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              ),
            ),
          ]),
          const SizedBox(height: 15),

          // Sélecteur durée
          Row(children: [
            const Text('Durée :', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 15),
            ChoiceChip(label: const Text('1 heure'), selected: _duration == 60, onSelected: (_) => setState(() => _duration = 60), selectedColor: AppTheme.primaryColor),
            const SizedBox(width: 10),
            ChoiceChip(label: const Text('2 heures'), selected: _duration == 120, onSelected: (_) => setState(() => _duration = 120), selectedColor: AppTheme.primaryColor),
          ]),
          const SizedBox(height: 25),

          // Planning du jour
          const Text('CRÉNEAUX DU JOUR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          const SizedBox(height: 12),

          ...hours.map((hour) {
            final hasSession = daySessions.any((s) => s.startTime.hour == hour);
            final session = hasSession ? daySessions.firstWhere((s) => s.startTime.hour == hour) : null;
            final endHour = _duration == 60 ? hour + 1 : hour + 2;
            final conflict = daySessions.any((s) => 
              s.startTime.hour < endHour && s.startTime.hour + (s.durationMinutes ~/ 60) > hour && s.startTime.hour != hour
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: hasSession 
                ? (session!.isBooked ? AppTheme.secondaryColor.withOpacity(0.15) : AppTheme.accentColor.withOpacity(0.1))
                : (conflict ? Colors.grey.withOpacity(0.05) : null),
              child: ListTile(
                leading: Icon(
                  hasSession ? (session!.isBooked ? Icons.person : Icons.lock_open) : Icons.add_circle_outline,
                  color: hasSession ? (session!.isBooked ? AppTheme.secondaryColor : AppTheme.accentColor) : Colors.white38,
                ),
                title: Text('${hour}h00 - ${endHour}h00', style: TextStyle(fontWeight: FontWeight.w600, color: conflict && !hasSession ? Colors.white24 : null)),
                subtitle: hasSession ? Text(session!.isBooked ? '${session.clientName} • ${session.durationMinutes}min' : 'Disponible • ${session.durationMinutes}min', style: TextStyle(color: session.isBooked ? AppTheme.secondaryColor : AppTheme.accentColor)) : null,
                trailing: hasSession
                  ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () { api.deleteSession(session!.id); setState(() {}); })
                  : (conflict ? null : IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.accentColor), onPressed: () => _addSlot(hour))),
              ),
            );
          }),
        ]),
      ),
    );
  }
}
