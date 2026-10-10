import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

/// Demande confirmation puis déconnecte (tokens + cache effacés).
/// L'app revient seule sur l'écran de login via `AuthStatus`.
Future<void> confirmAndLogout(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final auth = context.read<AuthController>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.logoutTitle),
      content: Text(l10n.logoutMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.logout),
        ),
      ],
    ),
  );
  if (confirmed ?? false) await auth.logout();
}
