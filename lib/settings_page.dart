// Suggested code may be subject to a license. Learn more: ~LicenseLog:953426324.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3579173113.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1155805010.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2451662343.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:378090368.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:4004007124.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double? _height;
  double? _weight;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _height = prefs.getDouble('height') ?? 170; // Default height: 170 cm
      _weight = prefs.getDouble('weight') ?? 70;  // Default weight: 70 kg
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('height', _height!);
    await prefs.setDouble('weight', _weight!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              onChanged: (value) {
                setState(() {
                  _height = double.tryParse(value) ?? 0;
                });
              },
              controller: TextEditingController(text: _height?.toStringAsFixed(0)),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              onChanged: (value) {
                setState(() {
                  _weight = double.tryParse(value) ?? 0;
                });
              },
              controller: TextEditingController(text: _weight?.toStringAsFixed(0)),
            ),
            ElevatedButton(
              onPressed: () {
                _saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
