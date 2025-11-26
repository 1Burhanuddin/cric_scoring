import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cric_scoring/providers/match_creation_provider.dart';
import 'package:cric_scoring/screens/match/playing_xi_screen.dart';

class NewMatchScreen extends ConsumerStatefulWidget {
  const NewMatchScreen({super.key});

  @override
  ConsumerState<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends ConsumerState<NewMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groundController = TextEditingController();

  @override
  void dispose() {
    _groundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);
    final teamsAsync = ref.watch(teamsProvider);
    final tournamentsAsync = ref.watch(activeTournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Match'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Tournament dropdown
            tournamentsAsync.when(
              data: (tournaments) {
                return DropdownButtonFormField<String>(
                  value: state.tournamentId,
                  decoration: const InputDecoration(
                    labelText: 'Tournament (Optional)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('No Tournament')),
                    ...tournaments.map((t) => DropdownMenuItem(
                          value: t.tournamentId,
                          child: Text(t.name),
                        )),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final tournament = tournaments
                          .firstWhere((t) => t.tournamentId == value);
                      notifier.setTournament(value, tournament.name);
                    } else {
                      notifier.setTournament(null, null);
                    }
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 12),

            // Team A dropdown
            teamsAsync.when(
              data: (teams) {
                final teamAId = state.teamA?.teamId;
                return DropdownButtonFormField<String>(
                  value: teamAId,
                  decoration: const InputDecoration(
                    labelText: 'Team A *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) => value == null ? 'Select Team A' : null,
                  items: teams
                      .map((t) => DropdownMenuItem(
                            value: t.teamId,
                            child: Text(t.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final team = teams.firstWhere((t) => t.teamId == value);
                      notifier.setTeamA(team);
                    }
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading teams'),
            ),
            const SizedBox(height: 12),

            // Team B dropdown
            teamsAsync.when(
              data: (teams) {
                final teamBId = state.teamB?.teamId;
                final teamAId = state.teamA?.teamId;
                return DropdownButtonFormField<String>(
                  value: teamBId,
                  decoration: const InputDecoration(
                    labelText: 'Team B *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) {
                    if (value == null) return 'Select Team B';
                    if (value == teamAId) return 'Team B must be different';
                    return null;
                  },
                  items: teams
                      .map((t) => DropdownMenuItem(
                            value: t.teamId,
                            child: Text(t.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final team = teams.firstWhere((t) => t.teamId == value);
                      notifier.setTeamB(team);
                    }
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading teams'),
            ),
            const SizedBox(height: 12),

            // Overs selection
            DropdownButtonFormField<int>(
              value: state.overs,
              decoration: const InputDecoration(
                labelText: 'Match Format (Overs) *',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [10, 15, 20, 30, 40, 50]
                  .map((overs) => DropdownMenuItem(
                        value: overs,
                        child: Text('$overs Overs'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) notifier.setOvers(value);
              },
            ),
            const SizedBox(height: 12),

            // Ground/Location
            TextFormField(
              controller: _groundController,
              decoration: const InputDecoration(
                labelText: 'Ground/Location *',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Enter ground name' : null,
              onChanged: (value) => notifier.setGround(value),
            ),
            const SizedBox(height: 12),

            // Date & Time picker
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              title: const Text('Match Date & Time'),
              subtitle: Text(
                '${state.matchDate.day}/${state.matchDate.month}/${state.matchDate.year} '
                '${state.matchDate.hour}:${state.matchDate.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: state.matchDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 7)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(state.matchDate),
                  );
                  if (time != null) {
                    notifier.setMatchDate(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ));
                  }
                }
              },
            ),
            const SizedBox(height: 12),

            // Ball type
            DropdownButtonFormField<String>(
              value: state.ballType,
              decoration: const InputDecoration(
                labelText: 'Ball Type *',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'tennis', child: Text('Tennis Ball')),
                DropdownMenuItem(value: 'hard', child: Text('Hard Ball')),
              ],
              onChanged: (value) {
                if (value != null) notifier.setBallType(value);
              },
            ),
            const SizedBox(height: 24),

            // Next button
            ElevatedButton(
              onPressed: state.isBasicInfoValid
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayingXIScreen(),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Next: Select Playing XI'),
            ),
          ],
        ),
      ),
    );
  }
}
