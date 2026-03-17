import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/services/auth_service.dart';
import '../auth/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _darkMode = false;
  bool _colorblindMode = false;
  String _language = 'Español';

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  Future<void> _loadLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _colorblindMode = prefs.getBool('colorblind_mode') ?? false;
      _language = prefs.getString('language') ?? 'Español';
    });
  }

  Future<void> _saveLocalSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Configuración',
            style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: SmarturStyle.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Apariencia ──────────────────────────────────────────────
          _buildSectionHeader('Apariencia'),
          SwitchListTile(
            title: const Text('Modo Oscuro',
                style: TextStyle(fontFamily: 'Outfit')),
            secondary: const Icon(Icons.dark_mode_outlined,
                color: SmarturStyle.purple),
            value: _darkMode,
            activeTrackColor: SmarturStyle.purple.withAlpha(100),
            thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? SmarturStyle.purple : null),
            onChanged: (val) {
              setState(() => _darkMode = val);
              _saveLocalSetting('dark_mode', val);
              SmarturNotifications.showInfo(
                  context, 'Modo oscuro se implementará pronto');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined,
                color: SmarturStyle.purple),
            title:
                const Text('Idioma', style: TextStyle(fontFamily: 'Outfit')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_language,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: SmarturStyle.textSecondary)),
                const Icon(Icons.chevron_right,
                    color: SmarturStyle.textSecondary),
              ],
            ),
            onTap: () => _showLanguageDialog(),
          ),
          SwitchListTile(
            title: const Text('Modo Daltónico',
                style: TextStyle(fontFamily: 'Outfit')),
            secondary: const Icon(Icons.visibility_outlined,
                color: SmarturStyle.purple),
            value: _colorblindMode,
            activeTrackColor: SmarturStyle.purple.withAlpha(100),
            thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? SmarturStyle.purple : null),
            onChanged: (val) {
              setState(() => _colorblindMode = val);
              _saveLocalSetting('colorblind_mode', val);
              SmarturNotifications.showInfo(
                  context, 'Modo daltónico se implementará pronto');
            },
          ),

          const Divider(height: 32),

          // ── Cuenta ──────────────────────────────────────────────────
          _buildSectionHeader('Cuenta'),
          ListTile(
            leading:
                const Icon(Icons.lock_outline, color: SmarturStyle.blue),
            title: const Text('Cambiar Contraseña',
                style: TextStyle(fontFamily: 'Outfit')),
            trailing: const Icon(Icons.chevron_right,
                color: SmarturStyle.textSecondary),
            onTap: () => _showChangePasswordSheet(),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: SmarturStyle.blue),
            title: const Text('Editar Nombre',
                style: TextStyle(fontFamily: 'Outfit')),
            trailing: const Icon(Icons.chevron_right,
                color: SmarturStyle.textSecondary),
            onTap: () => _showEditNameDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: SmarturStyle.pink),
            title: const Text('Eliminar Cuenta',
                style: TextStyle(
                    fontFamily: 'Outfit', color: SmarturStyle.pink)),
            onTap: () => _confirmDeletion(context),
          ),

          const Divider(height: 32),

          // ── Información ─────────────────────────────────────────────
          _buildSectionHeader('Información'),
          const ListTile(
            leading: Icon(Icons.info_outline,
                color: SmarturStyle.textSecondary),
            title: Text('Versión de la App',
                style: TextStyle(fontFamily: 'Outfit')),
            trailing: Text('v1.0.0',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    color: SmarturStyle.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined,
                color: SmarturStyle.textSecondary),
            title: const Text('Términos y Condiciones',
                style: TextStyle(fontFamily: 'Outfit')),
            trailing: const Icon(Icons.chevron_right,
                color: SmarturStyle.textSecondary),
            onTap: () => SmarturNotifications.showInfo(
                context, 'Abriendo TyC...'),
          ),

          const SizedBox(height: 24),

          // ── Cerrar Sesión ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () => _logout(),
              icon: const Icon(Icons.logout, color: SmarturStyle.pink),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    color: SmarturStyle.pink,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SmarturStyle.pink),
                minimumSize: const Size(
                    double.infinity, SmarturStyle.touchTargetComfortable),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers UI ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: SmarturStyle.textSecondary,
        ),
      ),
    );
  }

  // ── Idioma ──────────────────────────────────────────────────────────────

  void _showLanguageDialog() {
    final languages = ['Español', 'English', 'Français', 'Português'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Seleccionar Idioma',
                style:
                    SmarturStyle.calSansTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            ...languages.map((lang) => ListTile(
                  title: Text(lang,
                      style: const TextStyle(fontFamily: 'Outfit')),
                  trailing: _language == lang
                      ? const Icon(Icons.check_circle,
                          color: SmarturStyle.purple)
                      : null,
                  onTap: () {
                    setState(() => _language = lang);
                    _saveLocalSetting('language', lang);
                    Navigator.pop(ctx);
                    SmarturNotifications.showSuccess(
                        context, 'Idioma cambiado a $lang');
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Cambiar Contraseña ─────────────────────────────────────────────────

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _ChangePasswordSheet(),
    );
  }

  // ── Editar Nombre ──────────────────────────────────────────────────────

  void _showEditNameDialog() async {
    final currentName = await _authService.getUserName() ?? '';
    final controller = TextEditingController(text: currentName);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title:
            const Text('Editar nombre', style: SmarturStyle.calSansTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Tu nombre',
            hintStyle: const TextStyle(fontFamily: 'Outfit'),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: SmarturStyle.purple, width: 2),
            ),
          ),
          style: const TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: SmarturStyle.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SmarturStyle.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await _authService.updateUser({"name": newName});
                if (mounted) {
                  SmarturNotifications.showSuccess(
                      context, 'Nombre actualizado correctamente');
                }
              } on AuthException catch (e) {
                if (mounted) {
                  SmarturNotifications.showError(context, e.message);
                }
              }
            },
            child: const Text('Guardar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Eliminar Cuenta ────────────────────────────────────────────────────

  void _confirmDeletion(BuildContext parentCtx) {
    showDialog(
      context: parentCtx,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar cuenta',
            style: SmarturStyle.calSansTitle),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta? '
          'Esta acción es irreversible y perderás tu historial de viajes.',
          style: TextStyle(
              fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: SmarturStyle.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: SmarturStyle.pink),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _authService.deactivateAccount();
                if (parentCtx.mounted) {
                  Navigator.pushAndRemoveUntil(
                    parentCtx,
                    MaterialPageRoute(builder: (_) => WelcomeScreen()),
                    (_) => false,
                  );
                }
              } on AuthException catch (e) {
                if (parentCtx.mounted) {
                  SmarturNotifications.showError(parentCtx, e.message);
                }
              }
            },
            child: const Text('Sí, eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Cerrar Sesión ──────────────────────────────────────────────────────

  Future<void> _logout() async {
    await _authService.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
        (_) => false,
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Bottom Sheet: Cambiar Contraseña (forgot → código → reset)
// ═══════════════════════════════════════════════════════════════════════════

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  int _step = 0; // 0 = enviar código, 1 = ingresar código + nueva contraseña
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String _email = '';
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await _auth.getUserEmail();
    if (mounted && email != null) setState(() => _email = email);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_email.isEmpty) {
      SmarturNotifications.showError(context, 'No se encontró tu email');
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.forgotPassword(_email);
      if (mounted) {
        setState(() {
          _step = 1;
          _loading = false;
        });
        SmarturNotifications.showSuccess(
            context, 'Código enviado a $_email');
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        SmarturNotifications.showError(context, e.message);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.resetPassword(
          _email, _codeCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        Navigator.pop(context);
        SmarturNotifications.showSuccess(
            context, 'Contraseña actualizada correctamente');
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        SmarturNotifications.showError(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cambiar Contraseña',
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              _step == 0
                  ? 'Te enviaremos un código de verificación a tu correo electrónico.'
                  : 'Ingresa el código y tu nueva contraseña.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  color: SmarturStyle.textSecondary,
                  fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (_step == 0) _buildStep0(),
            if (_step == 1) _buildStep1(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: SmarturStyle.bgSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_outlined,
                  color: SmarturStyle.purple, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _email.isNotEmpty ? _email : 'Cargando...',
                  style: const TextStyle(
                      fontFamily: 'Outfit', fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: SmarturStyle.touchTargetComfortable,
          child: ElevatedButton(
            onPressed: _loading ? null : _sendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: SmarturStyle.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : const Text('Enviar código',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: _inputDecoration(
              label: 'Código de verificación',
              icon: Icons.pin_outlined,
            ),
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                letterSpacing: 8,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            validator: (v) =>
                (v == null || v.trim().length < 6) ? 'Código de 6 dígitos' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscureNew,
            decoration: _inputDecoration(
              label: 'Nueva contraseña',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    color: SmarturStyle.textSecondary),
                onPressed: () =>
                    setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            style: const TextStyle(fontFamily: 'Outfit'),
            validator: (v) {
              if (v == null || v.length < 8) {
                return 'Mínimo 8 caracteres';
              }
              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                return 'Incluye al menos una mayúscula';
              }
              if (!RegExp(r'[a-z]').hasMatch(v)) {
                return 'Incluye al menos una minúscula';
              }
              if (!RegExp(r'[0-9]').hasMatch(v)) {
                return 'Incluye al menos un número';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            decoration: _inputDecoration(
              label: 'Confirmar contraseña',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: SmarturStyle.textSecondary),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            style: const TextStyle(fontFamily: 'Outfit'),
            validator: (v) =>
                v != _passCtrl.text ? 'Las contraseñas no coinciden' : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: SmarturStyle.touchTargetComfortable,
            child: ElevatedButton(
              onPressed: _loading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: SmarturStyle.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Actualizar contraseña',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : _sendCode,
            child: const Text('Reenviar código',
                style: TextStyle(
                    fontFamily: 'Outfit', color: SmarturStyle.purple)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Outfit'),
      prefixIcon: Icon(icon, color: SmarturStyle.purple),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SmarturStyle.purple, width: 2),
      ),
      filled: true,
      fillColor: SmarturStyle.bgSecondary,
    );
  }
}
