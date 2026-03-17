import 'package:flutter/material.dart';
import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';

/// Paso 2: Intereses, nivel de actividad, tipo de viaje y lugar preferido
class PreferencesStep2 extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PreferencesStep2({super.key, required this.data, required this.onNext, required this.onBack});

  @override
  State<PreferencesStep2> createState() => _PreferencesStep2State();
}

class _PreferencesStep2State extends State<PreferencesStep2> {
  final _interestOptions = [
    {'label': 'Cultura', 'icon': Icons.museum_outlined},
    {'label': 'Gastronomía', 'icon': Icons.restaurant_outlined},
    {'label': 'Aventura', 'icon': Icons.terrain},
    {'label': 'Naturaleza', 'icon': Icons.park_outlined},
    {'label': 'Historia', 'icon': Icons.account_balance_outlined},
    {'label': 'Fotografía', 'icon': Icons.camera_alt_outlined},
    {'label': 'Deportes', 'icon': Icons.sports_soccer},
    {'label': 'Bienestar', 'icon': Icons.spa_outlined},
    {'label': 'Arte', 'icon': Icons.palette_outlined},
    {'label': 'Nightlife', 'icon': Icons.nightlife},
  ];

  final _activityLevels = ['Bajo', 'Moderado', 'Alto', 'Extremo'];
  final _travelTypes = ['Mochilero', 'Familiar', 'Lujo', 'Aventura', 'Romántico', 'De negocios'];
  final _preferredPlaces = ['Playa', 'Montaña', 'Ciudad', 'Campo', 'Bosque', 'Desierto'];

  Set<String> _selectedInterests = {};
  String? _activityLevel;
  String? _travelType;
  String? _preferredPlace;

  @override
  void initState() {
    super.initState();
    final raw = widget.data['interests'];
    if (raw is String && raw.isNotEmpty) {
      _selectedInterests = raw.split(', ').toSet();
    } else if (raw is List) {
      _selectedInterests = raw.map((e) => e.toString()).toSet();
    }
    final rawActivity = widget.data['activity_level'];
    if (rawActivity is int) {
      if (rawActivity <= 1) {
        _activityLevel = 'Bajo';
      } else if (rawActivity <= 3) _activityLevel = 'Moderado';
      else if (rawActivity <= 4) _activityLevel = 'Alto';
      else _activityLevel = 'Extremo';
    } else {
      _activityLevel = rawActivity as String?;
    }
    _travelType = widget.data['travel_type'];
    _preferredPlace = widget.data['preferred_place'];
  }

  void _submit() {
    if (_selectedInterests.isEmpty) {
      SmarturNotifications.showError(context, 'Selecciona al menos un interés');
      return;
    }
    if (_activityLevel == null || _travelType == null || _preferredPlace == null) {
      SmarturNotifications.showError(context, 'Completa todos los campos');
      return;
    }
    int activityValue = 3; // Moderado por defecto
    if (_activityLevel == 'Bajo') {
      activityValue = 1;
    } else if (_activityLevel == 'Moderado') activityValue = 3;
    else activityValue = 5; // Alto o Extremo

    widget.data['interests'] = _selectedInterests.toList();
    widget.data['activity_level'] = activityValue;
    widget.data['travel_type'] = _travelType;
    widget.data['preferred_place'] = _preferredPlace;
    widget.onNext();
  }

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SmarturStyle.purple),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: SmarturStyle.textPrimary, fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Intereses
        _sectionLabel('Tus intereses', Icons.favorite_outline),
        const SizedBox(height: SmarturStyle.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interestOptions.map((item) {
            final selected = _selectedInterests.contains(item['label']);
            return FilterChip(
              avatar: Icon(item['icon'] as IconData, size: 16, color: selected ? Colors.white : SmarturStyle.purple),
              label: Text(item['label'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: selected ? Colors.white : SmarturStyle.textPrimary)),
              selected: selected,
              showCheckmark: false,
              selectedColor: SmarturStyle.purple,
              backgroundColor: SmarturStyle.purple.withValues(alpha: 0.1),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? SmarturStyle.purple : SmarturStyle.purple.withValues(alpha: 0.2)),
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedInterests.add(item['label'] as String);
                  } else {
                    _selectedInterests.remove(item['label'] as String);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: SmarturStyle.spacingLg),

        // Nivel de actividad
        _sectionLabel('Nivel de actividad', Icons.bolt_outlined),
        const SizedBox(height: SmarturStyle.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _activityLevels.map((level) {
            final selected = _activityLevel == level;
            return ChoiceChip(
              label: Text(level, style: TextStyle(fontFamily: 'Outfit', color: selected ? Colors.white : SmarturStyle.textPrimary)),
              selected: selected,
              showCheckmark: false,
              selectedColor: SmarturStyle.pink,
              backgroundColor: SmarturStyle.pink.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? SmarturStyle.pink : SmarturStyle.pink.withValues(alpha: 0.2)),
              ),
              onSelected: (_) => setState(() => _activityLevel = level),
            );
          }).toList(),
        ),
        const SizedBox(height: SmarturStyle.spacingLg),

        // Tipo de viaje
        _sectionLabel('Tipo de viaje', Icons.luggage_outlined),
        const SizedBox(height: SmarturStyle.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _travelTypes.map((type) {
            final selected = _travelType == type;
            return ChoiceChip(
              label: Text(type, style: TextStyle(fontFamily: 'Outfit', color: selected ? Colors.white : SmarturStyle.textPrimary)),
              selected: selected,
              showCheckmark: false,
              selectedColor: SmarturStyle.blue,
              backgroundColor: SmarturStyle.blue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? SmarturStyle.blue : SmarturStyle.blue.withValues(alpha: 0.2)),
              ),
              onSelected: (_) => setState(() => _travelType = type),
            );
          }).toList(),
        ),
        const SizedBox(height: SmarturStyle.spacingLg),

        // Lugar preferido
        _sectionLabel('Lugar preferido', Icons.place_outlined),
        const SizedBox(height: SmarturStyle.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _preferredPlaces.map((place) {
            final selected = _preferredPlace == place;
            return ChoiceChip(
              label: Text(place, style: TextStyle(fontFamily: 'Outfit', color: selected ? Colors.white : SmarturStyle.textPrimary)),
              selected: selected,
              showCheckmark: false,
              selectedColor: SmarturStyle.green,
              backgroundColor: SmarturStyle.green.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? SmarturStyle.green : SmarturStyle.green.withValues(alpha: 0.2)),
              ),
              onSelected: (_) => setState(() => _preferredPlace = place),
            );
          }).toList(),
        ),
        const SizedBox(height: SmarturStyle.spacingXl),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SmarturStyle.purple),
                  minimumSize: const Size(double.infinity, SmarturStyle.touchTargetComfortable),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Atrás', style: TextStyle(color: SmarturStyle.purple, fontFamily: 'Outfit')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
