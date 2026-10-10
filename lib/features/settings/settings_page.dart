import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current =
        context.select<SettingsController, String?>((s) => s.locale?.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Semantics(
              header: true,
              child: Text(l10n.language, style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          _LanguageTile(label: l10n.languageSystem, locale: null, selected: current == null),
          _LanguageTile(
            label: l10n.languageFrench,
            locale: const Locale('fr'),
            selected: current == 'fr',
          ),
          _LanguageTile(
            label: l10n.languageEnglish,
            locale: const Locale('en'),
            selected: current == 'en',
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.selected,
  });

  final String label;
  final Locale? locale;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      selected: selected,
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () => context.read<SettingsController>().setLocale(locale),
    );
  }
}
