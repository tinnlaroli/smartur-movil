import 'package:flutter/material.dart';
import 'package:smartur/l10n/app_localizations.dart';
import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';

/// Paso 1: Datos Personales (edad, rango edad, género)
class PreferencesStep1 extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;

  const PreferencesStep1({super.key, required this.data, required this.onNext});

  @override
  State<PreferencesStep1> createState() => _PreferencesStep1State();
}

class _PreferencesStep1State extends State<PreferencesStep1> {
  final _formKey = GlobalKey<FormState>();

  final _birthYearController = TextEditingController();
  String? _selectedGender;

  List<Map<String, dynamic>> _genderOptions(AppLocalizations l10n) => [
    {'key': 'Masculino', 'label': l10n.genderMale, 'icon': Icons.male},
    {'key': 'Femenino', 'label': l10n.genderFemale, 'icon': Icons.female},
    {'key': 'No binario', 'label': l10n.genderNonBinary, 'icon': Icons.transgender},
    {'key': 'Prefiero no decir', 'label': l10n.genderPreferNotToSay, 'icon': Icons.remove_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.data['age'] != null) {
      final currentYear = DateTime.now().year;
      final age = widget.data['age'] as int;
      _birthYearController.text = (currentYear - age).toString();
    }
    _selectedGender = widget.data['gender'];
  }

  @override
  void dispose() {
    _birthYearController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      SmarturNotifications.showError(context, l10n.selectGender);
      return;
    }

    final birthYear = int.tryParse(_birthYearController.text.trim());
    if (birthYear == null) return;

    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear;

    String ageRange = '18-30';
    if (age < 18) {
      ageRange = 'Menor de 18';
    } else if (age <= 30) {
      ageRange = '18-30';
    } else if (age <= 45) {
      ageRange = '31-45';
    } else if (age <= 60) {
      ageRange = '46-60';
    } else {
      ageRange = 'Mayor de 60';
    }

    widget.data['age'] = age;
    widget.data['age_range'] = ageRange;
    widget.data['gender'] = _selectedGender;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final genders = _genderOptions(l10n);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _birthYearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.birthYear,
              prefixIcon: const Icon(Icons.calendar_today_outlined, color: SmarturStyle.purple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enterBirthYear;
              final n = int.tryParse(v);
              final currentYear = DateTime.now().year;
              if (n == null || n < 1900 || n > currentYear - 10) return l10n.invalidYear;
              return null;
            },
          ),
          const SizedBox(height: SmarturStyle.spacingLg),

          Text(
            l10n.gender,
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: scheme.onSurface),
          ),
          const SizedBox(height: SmarturStyle.spacingSm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: genders.map((g) {
              final selected = _selectedGender == g['key'];
              return ChoiceChip(
                avatar: Icon(g['icon'] as IconData, size: 18, color: selected ? Colors.white : SmarturStyle.purple),
                label: Text(g['label'] as String, style: TextStyle(fontFamily: 'Outfit', color: selected ? Colors.white : scheme.onSurface)),
                selected: selected,
                showCheckmark: false,
                selectedColor: SmarturStyle.purple,
                backgroundColor: SmarturStyle.purple.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: selected ? SmarturStyle.purple : SmarturStyle.purple.withValues(alpha: 0.2)),
                ),
                onSelected: (_) => setState(() => _selectedGender = g['key'] as String),
              );
            }).toList(),
          ),
          const SizedBox(height: SmarturStyle.spacingXl),

          ElevatedButton(
            onPressed: _submit,
            child: Text(l10n.next),
          ),
        ],
      ),
    );
  }
}
