import 'package:flutter/material.dart';
import 'match_details_screen.dart';

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildMatchesList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildMatchesList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Live Matches',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        _buildMatchCard(
          context,
          teamA: 'Mumbai Indians',
          teamALogo: 'MI',
          teamAColor: const Color(0xFF004BA0),
          teamB: 'Chennai Super Kings',
          teamBLogo: 'CSK',
          teamBColor: const Color(0xFFFDB913),
          date: 'Today',
          time: '7:30 PM',
          ground: 'Wankhede Stadium, Mumbai',
          status: 'LIVE',
          statusColor: Colors.red,
          score: 'MI 145/3 (16.4)',
        ),
        const SizedBox(height: 16),
        Text(
          'Upcoming Matches',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        _buildMatchCard(
          context,
          teamA: 'Royal Challengers',
          teamALogo: 'RCB',
          teamAColor: const Color(0xFFEC1C24),
          teamB: 'Kolkata Knight Riders',
          teamBLogo: 'KKR',
          teamBColor: const Color(0xFF3A225D),
          date: 'Tomorrow',
          time: '3:30 PM',
          ground: 'M. Chinnaswamy Stadium',
          status: 'UPCOMING',
          statusColor: Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildMatchCard(
          context,
          teamA: 'Delhi Capitals',
          teamALogo: 'DC',
          teamAColor: const Color(0xFF282968),
          teamB: 'Punjab Kings',
          teamBLogo: 'PBKS',
          teamBColor: const Color(0xFFED1B24),
          date: 'Dec 28',
          time: '7:30 PM',
          ground: 'Arun Jaitley Stadium',
          status: 'UPCOMING',
          statusColor: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text(
          'Completed Matches',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        _buildMatchCard(
          context,
          teamA: 'Mumbai Indians',
          teamALogo: 'MI',
          teamAColor: const Color(0xFF004BA0),
          teamB: 'Royal Challengers',
          teamBLogo: 'RCB',
          teamBColor: const Color(0xFFEC1C24),
          date: 'Dec 20',
          time: 'Completed',
          ground: 'Wankhede Stadium',
          status: 'COMPLETED',
          statusColor: Colors.grey,
          result: 'MI won by 7 runs',
        ),
        const SizedBox(height: 8),
        _buildMatchCard(
          context,
          teamA: 'Chennai Super Kings',
          teamALogo: 'CSK',
          teamAColor: const Color(0xFFFDB913),
          teamB: 'Kolkata Knight Riders',
          teamBLogo: 'KKR',
          teamBColor: const Color(0xFF3A225D),
          date: 'Dec 18',
          time: 'Completed',
          ground: 'M.A. Chidambaram Stadium',
          status: 'COMPLETED',
          statusColor: Colors.grey,
          result: 'KKR won by 6 wickets',
        ),
      ],
    );
  }

  Widget _buildMatchCard(
    BuildContext context, {
    required String teamA,
    required String teamALogo,
    required Color teamAColor,
    required String teamB,
    required String teamBLogo,
    required Color teamBColor,
    required String date,
    required String time,
    required String ground,
    required String status,
    required Color statusColor,
    String? score,
    String? result,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchDetailsScreen(
                teamA: teamA,
                teamALogo: teamALogo,
                teamAColor: teamAColor,
                teamB: teamB,
                teamBLogo: teamBLogo,
                teamBColor: teamBColor,
                status: status,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                    ),
                  ),
                  if (status == 'LIVE')
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: teamAColor,
                          child: Text(
                            teamALogo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          teamA,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'vs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: teamBColor,
                          child: Text(
                            teamBLogo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          teamB,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (score != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    score,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
              if (result != null) ...[
                const SizedBox(height: 10),
                Text(
                  result,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$date • $time',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      ground,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
