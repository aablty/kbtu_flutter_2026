import 'package:flutter/material.dart';

class CityFilter extends StatelessWidget {
  const CityFilter({
    required this.cities,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<String> cities;
  final String? value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'City filter',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      hint: const Text('All cities'),
      items: cities
          .map(
            (city) => DropdownMenuItem<String>(value: city, child: Text(city)),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );
}
