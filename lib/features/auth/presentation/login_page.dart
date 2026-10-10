import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/failure.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthController>();
    if (_register) {
      auth.register(_name.text.trim(), _email.text.trim(), _password.text);
    } else {
      auth.login(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // select : cette page ne se reconstruit que si busy / errorType changent.
    final busy = context.select<AuthController, bool>((a) => a.busy);
    final errorType =
        context.select<AuthController, FailureType?>((a) => a.errorType);

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
                  const ExcludeSemantics(child: Icon(Icons.storefront, size: 64)),
                  const SizedBox(height: 8),
                  Semantics(
                    header: true,
                    child: Text(
                      _register ? l10n.createAccountTitle : l10n.welcomeBack,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_register) ...[
                    TextFormField(
                      key: const Key('name'),
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    key: const Key('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || !_emailPattern.hasMatch(v.trim()))
                        ? l10n.invalidEmail
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('password'),
                    controller: _password,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip:
                            _hidePassword ? l10n.showPassword : l10n.hidePassword,
                        icon: Icon(
                          _hidePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 4) ? l10n.passwordTooShort : null,
                  ),
                  if (errorType != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.failureMessage(errorType),
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('submit'),
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_register ? l10n.signUp : l10n.signIn),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthController>().clearError();
                      setState(() => _register = !_register);
                    },
                    child: Text(_register ? l10n.haveAccount : l10n.noAccount),
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
