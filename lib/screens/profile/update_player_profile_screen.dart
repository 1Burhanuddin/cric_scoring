import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/providers/player_provider.dart';
import 'package:cric_scoring/providers/user_provider.dart';

class UpdatePlayerProfileScreen extends ConsumerStatefulWidget {
  const UpdatePlayerProfileScreen({super.key});

  @override
  ConsumerState<UpdatePlayerProfileScreen> createState() =>
      _UpdatePlayerProfileScreenState();
}

class _UpdatePlayerProfileScreenState
    extends ConsumerState<UpdatePlayerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jerseyController = TextEditingController();

  String _playerRole = 'batsman';
  String _battingStyle = 'right-hand';
  String? _bowlingStyle;

  @override
  void dispose() {
    _jerseyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login first')),
      );
    }

    // Pre-fill if user already has player profile
    if (user.hasPlayerProfile && _jerseyController.text.isEmpty) {
      _jerseyController.text = user.jerseyNumber.toString();
      _playerRole = user.playerRole!;
      _battingStyle = user.battingStyle!;
      _bowlingStyle = user.bowlingStyle;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user.hasPlayerProfile)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your player profile is complete. You can be added to teams!',
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _jerseyController,
              decoration: const InputDecoration(
                labelText: 'Jersey Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                helperText: 'Your shirt number (1-99)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter jersey number';
                }
                final num = int.tryParse(value);
                if (num == null || num < 1 || num > 99) {
                  return 'Please enter a number between 1-99';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _playerRole,
              decoration: const InputDecoration(
                labelText: 'Player Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_cricket),
                helperText: 'Your primary role in the team',
              ),
              items: const [
                DropdownMenuItem(value: 'batsman', child: Text('Batsman')),
                DropdownMenuItem(value: 'bowler', child: Text('Bowler')),
                DropdownMenuItem(
                    value: 'allrounder', child: Text('All-rounder')),
                DropdownMenuItem(
                    value: 'wicketkeeper', child: Text('Wicket Keeper')),
              ],
              onChanged: (value) => setState(() => _playerRole = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _battingStyle,
              decoration: const InputDecoration(
                labelText: 'Batting Style',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_baseball),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'right-hand', child: Text('Right Hand Bat')),
                DropdownMenuItem(
                    value: 'left-hand', child: Text('Left Hand Bat')),
              ],
              onChanged: (value) => setState(() => _battingStyle = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bowlingStyle,
              decoration: const InputDecoration(
                labelText: 'Bowling Style (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_tennis),
                helperText: 'Leave empty if you don\'t bowl',
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('None')),
                DropdownMenuItem(
                    value: 'right-arm-fast', child: Text('Right Arm Fast')),
                DropdownMenuItem(
                    value: 'left-arm-fast', child: Text('Left Arm Fast')),
                DropdownMenuItem(
                    value: 'right-arm-medium', child: Text('Right Arm Medium')),
                DropdownMenuItem(
                    value: 'left-arm-medium', child: Text('Left Arm Medium')),
                DropdownMenuItem(
                    value: 'right-arm-spin', child: Text('Right Arm Spin')),
                DropdownMenuItem(
                    value: 'left-arm-spin', child: Text('Left Arm Spin')),
              ],
              onChanged: (value) => setState(() => _bowlingStyle = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Player Profile',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      await ref.read(playerProviderNotifier.notifier).updateUserPlayerProfile(
            userId: user.uid,
            jerseyNumber: int.parse(_jerseyController.text),
            playerRole: _playerRole,
            battingStyle: _battingStyle,
            bowlingStyle: _bowlingStyle,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
