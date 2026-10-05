import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController(text: 'john@mail.com');
  final _pass = TextEditingController(text: 'changeme');
  bool _register = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    _register
        ? auth.register(_name.text.trim(), _email.text.trim(), _pass.text)
        : auth.login(_email.text.trim(), _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.storefront, size: 64),
                  const SizedBox(height: 8),
                  Text(_register ? 'Créer un compte' : 'Connexion',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  if (_register) ...[
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.length < 4) ? '4 caractères minimum' : null,
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.busy ? null : _submit,
                      child: auth.busy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_register ? 'S’inscrire' : 'Se connecter'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      auth.clearError();
                      setState(() => _register = !_register);
                    },
                    child: Text(_register ? 'J’ai déjà un compte' : 'Pas de compte ? S’inscrire'),
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
