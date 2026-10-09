import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (_register) {
        await auth.signUp(email: _email.text.trim(), password: _password.text);
      } else {
        await auth.signInWithPassword(email: _email.text.trim(), password: _password.text);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No se pudo conectar. Revisa tu internet e inténtalo otra vez.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(26), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420), child: Form(
          key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 76, height: 76, alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.explore_rounded, size: 40, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 24),
            Text('Mis lugares favoritos', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(_register ? 'Crea tu cuenta para guardar tus recuerdos.' : 'Inicia sesión para ver tus lugares.', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 28),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline)),
              validator: (v) => v == null || !v.contains('@') ? 'Escribe un correo válido' : null),
            const SizedBox(height: 14),
            TextFormField(controller: _password, obscureText: _hidePassword,
              decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off))),
              validator: (v) => v == null || v.length < 6 ? 'Usa al menos 6 caracteres' : null),
            if (_error != null) ...[const SizedBox(height: 14), Text(_error!, style: const TextStyle(color: Colors.red))],
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _submit,
              child: Padding(padding: const EdgeInsets.all(14), child: _busy
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_register ? 'Crear cuenta' : 'Iniciar sesión'))),
            TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }),
              child: Text(_register ? 'Ya tengo cuenta · Iniciar sesión' : '¿Primera vez? Crear cuenta')),
          ]),
        ),
      ),
    ))),
  );
}
