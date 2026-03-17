import 'package:flutter/material.dart';
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

class 
_PreferencesStep1State extends State<PreferencesStep1> {
  final _formKey = GlobalKey<FormState>();

  final _birthYearController = TextEditingController();
  String? _selectedGender;

  final List<Map<String, dynamic>> _genders = [
    {'label': 'Masculino', 'icon': Icons.male},
    {'label': 'Femenino', 'icon': Icons.female},
    {'label': 'No binario', 'icon': Icons.transgender},
    {'label': 'Prefiero no decir', 'icon': Icons.remove_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    // Restore from shared data if user navigates back
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      SmarturNotifications.showError(context, 'Por favor selecciona tu género');
      return;
    }

    final birthYear = int.tryParse(_birthYearController.text.trim());
    if (birthYear == null) return;

    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear;

    String ageRange = '18-30'; // Default
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Año de nacimiento
          TextFormField(
            controller: _birthYearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Año de nacimiento',
              prefixIcon: const Icon(Icons.calendar_today_outlined, color: SmarturStyle.purple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu año de nacimiento';
              final n = int.tryParse(v);
              final currentYear = DateTime.now().year;
              if (n == null || n < 1900 || n > currentYear - 10) return 'Año no válido';
              return null;
            },
          ),
          const SizedBox(height: SmarturStyle.spacingLg),

          // Género — chips de selección
          const Text(
            'Género',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: SmarturStyle.textPrimary),
          ),
          const SizedBox(height: SmarturStyle.spacingSm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _genders.map((g) {
              final selected = _selectedGender == g['label'];
              return ChoiceChip(
                avatar: Icon(g['icon'] as IconData, size: 18, color: selected ? Colors.white : SmarturStyle.purple),
                label: Text(g['label'] as String, style: TextStyle(fontFamily: 'Outfit', color: selected ? Colors.white : SmarturStyle.textPrimary)),
                selected: selected,
                showCheckmark: false,
                selectedColor: SmarturStyle.purple,
                backgroundColor: SmarturStyle.purple.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: selected ? SmarturStyle.purple : SmarturStyle.purple.withValues(alpha: 0.2)),
                ),
                onSelected: (_) => setState(() => _selectedGender = g['label'] as String),
              );
            }).toList(),
          ),
          const SizedBox(height: SmarturStyle.spacingXl),

          ElevatedButton(
            onPressed: _submit,
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}
