import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/async_controller.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => AsyncController<User>(c.read<AuthRepository>().getProfile)..load(),
      child: AsyncView<User>(
        builder: (context, u) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(u.avatar),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(u.name, style: Theme.of(context).textTheme.headlineSmall)),
            Center(child: Text(u.email)),
            const SizedBox(height: 8),
            Center(child: Chip(label: Text(u.role))),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthController>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
