import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cricheros_data/api/match/match_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cricheros/components/app_page.dart';
import 'package:cricheros/components/error_screen.dart';
import 'package:cricheros/components/error_snackbar.dart';
import 'package:cricheros/domain/extensions/widget_extension.dart';
import 'package:cricheros/ui/flow/score_board/scorecard_share/scorecard_share_state.dart';
import 'package:cricheros/ui/flow/score_board/scorecard_share/scorecard_share_view_model.dart';
import 'package:cricheros_style/button/primary_button.dart';
import 'package:cricheros_style/indicator/progress_indicator.dart';
import 'package:cricheros_style/text/app_text_style.dart';

const _pitchTop = Color(0xFF1E7A46);
const _pitchBottom = Color(0xFF0B3D22);
const _accentRed = Color(0xFFE21C28);
const _cardSurface = Color(0x1AFFFFFF);
const _onCard = Color(0xFFFFFFFF);
const _onCardMuted = Color(0xCCFFFFFF);

class ScorecardShareScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ScorecardShareScreen({super.key, required this.matchId});

  @override
  ConsumerState createState() => _ScorecardShareScreenState();
}

class _ScorecardShareScreenState extends ConsumerState<ScorecardShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  late ScorecardShareViewNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = ref.read(scorecardShareStateProvider.notifier);
    runPostFrame(() => notifier.setData(widget.matchId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scorecardShareStateProvider);
    _observeActionError();
    _observeSavedFile();
    return AppPage(
      title: "Share Scorecard",
      body: Builder(builder: (context) => _body(context, state)),
    );
  }

  Widget _body(BuildContext context, ScorecardShareState state) {
    if (state.loading) {
      return const Center(child: AppProgressIndicator());
    }
    if (state.error != null) {
      return ErrorScreen(error: state.error, onRetryTap: notifier.loadData);
    }
    final match = state.match;
    if (match == null) {
      return const Center(child: AppProgressIndicator());
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              key: _cardKey,
              child: _scorecard(context, state, match),
            ),
          ),
        ),
        _actions(context, state),
      ],
    );
  }

  Widget _scorecard(
      BuildContext context, ScorecardShareState state, MatchModel match) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_pitchTop, _pitchBottom],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(match),
          const SizedBox(height: 20),
          ...match.teams.map((team) => _teamScoreRow(match, team)),
          const SizedBox(height: 16),
          _resultBanner(match),
          const SizedBox(height: 20),
          _performers(state),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Scored on CricHeros 🏏",
              style: AppTextStyle.caption.copyWith(color: _onCardMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(MatchModel match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "CricHeros",
          style: AppTextStyle.header3.copyWith(
            color: _onCard,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [match.ground, match.city]
              .where((e) => e.trim().isNotEmpty)
              .join(", "),
          textAlign: TextAlign.center,
          style: AppTextStyle.caption.copyWith(color: _onCardMuted),
        ),
      ],
    );
  }

  Widget _teamScoreRow(MatchModel match, MatchTeamModel team) {
    final isWinner = match.matchResult?.teamId == team.team.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: isWinner
              ? Border.all(color: const Color(0xFFFFD54F), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                team.team.name.isEmpty ? "Team" : team.team.name,
                style: AppTextStyle.subtitle1.copyWith(
                  color: _onCard,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${team.run}/${team.wicket}",
                  style: AppTextStyle.header3.copyWith(
                    color: _onCard,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "(${team.over} ov)",
                  style: AppTextStyle.caption.copyWith(color: _onCardMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultBanner(MatchModel match) {
    final result = match.matchResult;
    final text = _resultText(result);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: _accentRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.subtitle2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _resultText(MatchResult? result) {
    if (result == null) return "Match in progress";
    switch (result.winType) {
      case WinnerByType.tie:
        return "Match Tied";
      case WinnerByType.run:
        return "${result.teamName} won by ${result.difference} run${result.difference == 1 ? '' : 's'}";
      case WinnerByType.wicket:
        return "${result.teamName} won by ${result.difference} wicket${result.difference == 1 ? '' : 's'}";
    }
  }

  Widget _performers(ScorecardShareState state) {
    final batter = state.topBatter;
    final bowler = state.topBowler;
    if (batter == null && bowler == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _performerCard(
            "Top Batter",
            batter == null ? "—" : batter.name,
            batter == null
                ? ""
                : "${batter.runs} (${batter.balls}) · ${batter.fours}x4 ${batter.sixes}x6",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _performerCard(
            "Top Bowler",
            bowler == null ? "—" : bowler.name,
            bowler == null
                ? ""
                : "${bowler.wickets}/${bowler.runsConceded} (${bowler.overs} ov)",
          ),
        ),
      ],
    );
  }

  Widget _performerCard(String label, String name, String stat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyle.caption.copyWith(
              color: _onCardMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: AppTextStyle.subtitle2.copyWith(
              color: _onCard,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (stat.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              stat,
              style: AppTextStyle.caption.copyWith(color: _onCardMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, ScorecardShareState state) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                "Download",
                progress: state.isDownloading,
                background: const Color(0xFF18958F),
                onPressed: () => _onDownloadTap(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                "Share",
                progress: state.isSharing,
                background: _accentRed,
                onPressed: () => _onShareTap(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _captureCard() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _onShareTap() async {
    final bytes = await _captureCard();
    if (bytes == null) return;
    await notifier.shareScorecard(bytes);
  }

  Future<void> _onDownloadTap() async {
    final bytes = await _captureCard();
    if (bytes == null) return;
    await notifier.downloadScorecard(bytes);
  }

  void _observeActionError() {
    ref.listen(
      scorecardShareStateProvider.select((value) => value.actionError),
      (previous, next) {
        if (next != null) {
          showErrorSnackBar(context: context, error: next);
        }
      },
    );
  }

  void _observeSavedFile() {
    ref.listen(
      scorecardShareStateProvider.select((value) => value.savedFilePath),
      (previous, next) {
        if (next != null && next != previous) {
          showSnackBar(context, "Scorecard saved to $next");
        }
      },
    );
  }
}
