import 'package:flutter/material.dart';

class LiveScoringScreen extends StatefulWidget {
  final String teamA;
  final String teamALogo;
  final Color teamAColor;
  final String teamB;
  final String teamBLogo;
  final Color teamBColor;

  const LiveScoringScreen({
    super.key,
    required this.teamA,
    required this.teamALogo,
    required this.teamAColor,
    required this.teamB,
    required this.teamBLogo,
    required this.teamBColor,
  });

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  // Match state
  int runs = 145;
  int wickets = 3;
  double overs = 16.4;
  List<String> currentOver = ['1', '4', '0', '6', '2'];

  // Current players
  String striker = 'R. Sharma';
  int strikerRuns = 52;
  int strikerBalls = 34;
  int striker4s = 6;
  int striker6s = 2;

  String nonStriker = 'S. Yadav';
  int nonStrikerRuns = 38;
  int nonStrikerBalls = 28;

  // Current bowler
  String bowler = 'J. Bumrah';
  double bowlerOvers = 3.4;
  int bowlerMaidens = 0;
  int bowlerRuns = 24;
  int bowlerWickets = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scoring'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMatchHeader(context),
                  _buildCurrentScore(context),
                  _buildCurrentBatsmen(context),
                  _buildCurrentBowler(context),
                  _buildCurrentOver(context),
                  const SizedBox(height: 80), // Space for sticky controls
                ],
              ),
            ),
          ),
          _buildScoringControls(context),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: widget.teamAColor,
                child: Text(
                  widget.teamALogo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.teamA,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'vs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: widget.teamBColor,
                child: Text(
                  widget.teamBLogo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.teamB,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScore(BuildContext context) {
    double runRate = runs / overs;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            widget.teamA,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$runs/$wickets',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '($overs)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Run Rate: ${runRate.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBatsmen(BuildContext context) {
    double strikerSR = (strikerRuns / strikerBalls * 100);
    double nonStrikerSR = (nonStrikerRuns / nonStrikerBalls * 100);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Batsmen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sports_cricket,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$striker*',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Text(
                        '$strikerRuns ($strikerBalls)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '4s: $striker4s  6s: $striker6s  SR: ${strikerSR.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          nonStriker,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '$nonStrikerRuns ($nonStrikerBalls)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'SR: ${nonStrikerSR.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBowler(BuildContext context) {
    double economy = bowlerRuns / bowlerOvers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bowler',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sports_baseball,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bowler,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Text(
                        '$bowlerOvers-$bowlerMaidens-$bowlerRuns-$bowlerWickets',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Econ: ${economy.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOver(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Over',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (currentOver.length == 6)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Over Complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentOver.map((ball) {
                  Color ballColor = _getBallColor(ball);
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ballColor.withOpacity(0.1),
                      border: Border.all(color: ballColor, width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        ball,
                        style: TextStyle(
                          color: ballColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBallColor(String ball) {
    if (ball == 'W') return Colors.red;
    if (ball == '4') return Colors.green;
    if (ball == '6') return Colors.purple;
    if (ball == 'Wd' || ball == 'Nb') return Colors.orange;
    return Colors.grey;
  }

  Widget _buildScoringControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Run buttons
              Row(
                children: [
                  Expanded(
                    child: _buildRunButton(context, '0', Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildRunButton(context, '1', Colors.blue),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildRunButton(context, '2', Colors.blue),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildRunButton(context, '3', Colors.blue),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildRunButton(context, '4', Colors.green),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildRunButton(context, '6', Colors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Extras and Wicket
              Row(
                children: [
                  Expanded(
                    child: _buildExtraButton(context, 'Wd', Colors.orange),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildExtraButton(context, 'Nb', Colors.orange),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildExtraButton(context, 'Bye', Colors.teal),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildExtraButton(context, 'Lb', Colors.teal),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: _buildWicketButton(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Undo button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _undoLastBall(),
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo Last Ball'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunButton(BuildContext context, String runs, Color color) {
    return ElevatedButton(
      onPressed: () => _addRuns(runs),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        runs,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExtraButton(BuildContext context, String extra, Color color) {
    return ElevatedButton(
      onPressed: () => _addExtra(extra),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        extra,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWicketButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showWicketDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'WICKET',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _addRuns(String runs) {
    setState(() {
      currentOver.add(runs);
      // Update score logic here
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$runs run(s) added'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _addExtra(String extra) {
    setState(() {
      currentOver.add(extra);
      // Update score logic here
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$extra added'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showWicketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wicket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select wicket type:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildWicketTypeChip(context, 'Bowled'),
                _buildWicketTypeChip(context, 'Caught'),
                _buildWicketTypeChip(context, 'LBW'),
                _buildWicketTypeChip(context, 'Run Out'),
                _buildWicketTypeChip(context, 'Stumped'),
                _buildWicketTypeChip(context, 'Hit Wicket'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildWicketTypeChip(BuildContext context, String type) {
    return ActionChip(
      label: Text(type),
      onPressed: () {
        Navigator.pop(context);
        _addWicket(type);
      },
    );
  }

  void _addWicket(String type) {
    setState(() {
      currentOver.add('W');
      wickets++;
      // Show new batsman selection dialog
    });

    _showNewBatsmanDialog(context);
  }

  void _showNewBatsmanDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select New Batsman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('H. Pandya'),
              onTap: () {
                Navigator.pop(context);
                // Update batsman logic
              },
            ),
            ListTile(
              title: const Text('R. Jadeja'),
              onTap: () {
                Navigator.pop(context);
                // Update batsman logic
              },
            ),
            ListTile(
              title: const Text('K. Yadav'),
              onTap: () {
                Navigator.pop(context);
                // Update batsman logic
              },
            ),
          ],
        ),
      ),
    );
  }

  void _undoLastBall() {
    if (currentOver.isNotEmpty) {
      setState(() {
        currentOver.removeLast();
        // Undo score logic here
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Last ball undone'),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Change Strike'),
              onTap: () {
                Navigator.pop(context);
                // Swap striker and non-striker
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Change Bowler'),
              onTap: () {
                Navigator.pop(context);
                // Show bowler selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop),
              title: const Text('End Innings'),
              onTap: () {
                Navigator.pop(context);
                // End innings logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('End Match'),
              onTap: () {
                Navigator.pop(context);
                // End match logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
