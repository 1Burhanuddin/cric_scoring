import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cric_scoring/providers/team_provider.dart';
import 'package:cric_scoring/providers/match_provider.dart';
import 'package:cric_scoring/models/team_model.dart';

class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groundController = TextEditingController();

  Team? _teamA;
  Team? _teamB;
  int _overs = 20;
  String _ballType = 'tennis';
  DateTime _matchDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _groundController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _matchDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_matchDate),
      );

      if (time != null) {
        setState(() {
          _matchDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createMatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_teamA == null || _teamB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both teams')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(matchProviderNotifier.notifier).createMatch(
            teamA: _teamA!,
            teamB: _teamB!,
            overs: _overs,
            ground: _groundController.text.trim(),
            date: _matchDate,
            ballType: _ballType,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teamsAsync = ref.watch(teamsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: teamsAsync.when(
        data: (teams) {
          if (teams.length < 2) {
            return _buildInsufficientTeams(context);
          }
          return _buildForm(context, theme, teams);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildInsufficientTeams(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Need at least 2 teams',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create teams first to start a match',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.add),
              label: const Text('Create Teams'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, List<Team> teams) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Teams Section
          Text(
            'Select Teams',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Team A Selection
          _buildTeamSelector(
            label: 'Team A',
            selectedTeam: _teamA,
            teams: teams,
            onSelect: (team) {
              setState(() => _teamA = team);
            },
          ),

          const SizedBox(height: 12),

          // VS Divider
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Team B Selection
          _buildTeamSelector(
            label: 'Team B',
            selectedTeam: _teamB,
            teams: teams.where((t) => t.teamId != _teamA?.teamId).toList(),
            onSelect: (team) {
              setState(() => _teamB = team);
            },
          ),

          const SizedBox(height: 24),

          // Match Details Section
          Text(
            'Match Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Overs Selection
          _buildOversSelector(theme),

          const SizedBox(height: 16),

          // Ground
          TextFormField(
            controller: _groundController,
            decoration: InputDecoration(
              labelText: 'Ground',
              hintText: 'e.g., Wankhede Stadium',
              prefixIcon: const Icon(Icons.stadium_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter ground name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Date & Time
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date & Time',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '${_matchDate.day}/${_matchDate.month}/${_matchDate.year} '
                '${_matchDate.hour}:${_matchDate.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ball Type
          _buildBallTypeSelector(theme),

          const SizedBox(height: 32),

          // Create Button
          FilledButton(
            onPressed: _isLoading ? null : _createMatch,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Match',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSelector({
    required String label,
    required Team? selectedTeam,
    required List<Team> teams,
    required Function(Team) onSelect,
  }) {
    return InkWell(
      onTap: () => _showTeamPicker(teams, onSelect),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (selectedTeam != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(selectedTeam.color)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    selectedTeam.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedTeam.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      selectedTeam.city,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Icon(Icons.shield_outlined, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select $label',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  void _showTeamPicker(List<Team> teams, Function(Team) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Team',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(team.color)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          team.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(team.name),
                    subtitle: Text(team.city),
                    onTap: () {
                      onSelect(team);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildOversSelector(ThemeData theme) {
    final oversOptions = [10, 15, 20, 30, 40, 50];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overs',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: oversOptions.map((overs) {
            final isSelected = _overs == overs;
            return ChoiceChip(
              label: Text('$overs'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _overs = overs);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBallTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ball Type',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Tennis Ball'),
                selected: _ballType == 'tennis',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _ballType = 'tennis');
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Hard Ball'),
                selected: _ballType == 'hard',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _ballType = 'hard');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
