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
