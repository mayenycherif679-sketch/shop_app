import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/async_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/settings_page.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'logout.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AsyncController<User>(context.read<AuthRepository>().getProfile)..load(),
      child: AsyncView<User>(
        builder: (context, user) {
          final l10n = AppLocalizations.of(context);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: AppImage(
                  url: user.avatar,
                  width: 96,
                  height: 96,
                  borderRadius: BorderRadius.circular(48),
                  semanticLabel: user.name,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Semantics(
                  header: true,
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              Center(child: Text(user.email)),
              const SizedBox(height: 8),
              Center(child: Chip(label: Text(user.role))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => confirmAndLogout(context),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            ],
          );
        },
      ),
    );
  }
}
