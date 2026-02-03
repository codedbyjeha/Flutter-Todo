import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../widgets/themed_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _isSavingPassword = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Uint8List? _decodePhoto(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickPhoto(AuthProvider auth) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final encoded = base64Encode(bytes);
    await auth.updateProfilePhoto(encoded);
  }

  Future<void> _removePhoto(AuthProvider auth) async {
    await auth.updateProfilePhoto(null);
  }

  Future<void> _changePassword(AuthProvider auth) async {
    final current = _currentPassword.text.trim();
    final next = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    if (next != confirm) {
      _showSnack('Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isSavingPassword = true);
    final error = await auth.changePassword(
      currentPassword: current,
      newPassword: next,
    );
    setState(() => _isSavingPassword = false);

    if (error != null) {
      _showSnack(error);
      return;
    }

    _currentPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
    _showSnack('Password berhasil diubah');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout(AuthProvider auth) async {
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final photoBytes = _decodePhoto(user?.photoBase64);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: ThemedBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          Container(
            padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? scheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                  color: (Theme.of(context).cardTheme.shadowColor ??
                          Theme.of(context).shadowColor)
                      .withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: scheme.secondary.withOpacity(0.3),
                      backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                      child: photoBytes == null
                          ? Icon(Icons.person, size: 40, color: scheme.primary)
                          : null,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? scheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.primary.withOpacity(0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.photo_camera, size: 18),
                        color: scheme.primary,
                        onPressed: () => _pickPhoto(auth),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? '- ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola foto profil, password, dan sesi login',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(auth),
                        icon: const Icon(Icons.image),
                        label: const Text('Ganti Foto'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: photoBytes == null ? null : () => _removePhoto(auth),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Hapus Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? scheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                  color: (Theme.of(context).cardTheme.shadowColor ??
                          Theme.of(context).shadowColor)
                      .withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ganti Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _currentPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password lama',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password baru',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi password baru',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSavingPassword ? null : () => _changePassword(auth),
                    icon: const Icon(Icons.save),
                    label: Text(_isSavingPassword ? 'Menyimpan...' : 'Update Password'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? scheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                  color: (Theme.of(context).cardTheme.shadowColor ??
                          Theme.of(context).shadowColor)
                      .withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _ThemeSelector(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _logout(auth),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ThemeSelector extends StatefulWidget {
  @override
  State<_ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<_ThemeSelector> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final current = theme.themeName;
    final scheme = Theme.of(context).colorScheme;

    Widget buildCard({
      required String name,
      required String label,
      required List<Color> colors,
    }) {
      final bool selected = current == name;
      return Expanded(
        child: GestureDetector(
          onTap: () => theme.setTheme(name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? colors.first : scheme.onSurface.withOpacity(0.12),
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(selected ? 0.25 : 0.08),
                  blurRadius: selected ? 16 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: selected
                      ? const Icon(Icons.check_circle, key: ValueKey('on'), color: Colors.white)
                      : const Icon(Icons.circle_outlined, key: ValueKey('off'), color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildCard(
          name: 'light',
          label: 'Light',
          colors: [Colors.indigo.shade400, Colors.indigo.shade200],
        ),
        const SizedBox(width: 10),
        buildCard(
          name: 'dark',
          label: 'Dark',
          colors: [Colors.black87, Colors.black54],
        ),
        const SizedBox(width: 10),
        buildCard(
          name: 'pink',
          label: 'Pink Bubble',
          colors: const [Color(0xFFFF6FAE), Color(0xFFFFC3DA)],
        ),
      ],
    );
  }
}
