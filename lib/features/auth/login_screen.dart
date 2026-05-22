import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../client/client_dashboard.dart';
import '../coach/coach_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final api = context.read<ApiService>();
      final user = await api.login(_emailCtrl.text.trim(), _passCtrl.text);
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (user != null) {
          if (user.role == 'coach') {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const CoachDashboard()));
          } else {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => ClientDashboard(user: user)));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Email ou mot de passe incorrect, ou compte non validé.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
                  const Text('CONNEXION', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Content de vous revoir !', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 45),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
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
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SE CONNECTER', style: TextStyle(letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      _emailCtrl.text = 'coach@test.com';
                      _passCtrl.text = 'coach123';
                    },
                    child: const Text('🖥️ Accès Coach (démo)', style: TextStyle(color: Colors.white38)),
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
