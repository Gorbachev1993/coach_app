import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _coachCodeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _coachCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      if (_coachCodeCtrl.text.trim() != 'COACH2024') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Code coach invalide.'), backgroundColor: Colors.red),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final api = context.read<ApiService>();
      final existingUser = await api.findUserByEmail(_emailCtrl.text.trim());
      
      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Cet email est déjà utilisé.'), backgroundColor: Colors.red),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final user = UserModel(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        email: _emailCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        role: 'pending',
      );

      await api.registerPendingUser(user);

      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [
              Icon(Icons.check_circle, color: AppTheme.accentColor, size: 28),
              SizedBox(width: 10),
              Text('Inscription envoyée !', style: TextStyle(color: Colors.white)),
            ]),
            content: const Text(
              'Votre coach validera votre compte prochainement.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('INSCRIPTION')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.backgroundColor, AppTheme.surfaceColor]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CRÉER VOTRE COMPTE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Remplissez le formulaire', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 30),
                TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v?.isEmpty == true ? 'Requis' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v?.isEmpty == true ? 'Requis' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress, validator: (v) => v?.isEmpty == true ? 'Requis' : (!v!.contains('@') ? 'Email invalide' : null)),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock_outlined), helperText: 'Minimum 6 caractères'), obscureText: true, validator: (v) => v?.isEmpty == true ? 'Requis' : (v!.length < 6 ? 'Minimum 6 caractères' : null)),
                const SizedBox(height: 16),
                TextFormField(controller: _coachCodeCtrl, decoration: const InputDecoration(labelText: 'Code coach', prefixIcon: Icon(Icons.vpn_key_outlined), helperText: 'Fourni par votre coach'), validator: (v) => v?.isEmpty == true ? 'Code requis' : null),
                const SizedBox(height: 30),
                SizedBox(width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                    child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('S\'INSCRIRE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
