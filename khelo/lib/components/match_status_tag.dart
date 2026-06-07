import 'package:cricheros_data/api/match/match_model.dart';
import 'package:cricheros_data/api/tournament/tournament_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cricheros/domain/extensions/enum_extensions.dart';
import 'package:cricheros/gen/assets.gen.dart';
import 'package:cricheros_style/animations/on_tap_scale.dart';
import 'package:cricheros_style/extensions/context_extensions.dart';
import 'package:cricheros_style/text/app_text_style.dart';

class StatusTag extends StatelessWidget {
  final MatchStatus? matchStatus;
  final TournamentStatus? tournamentStatus;
  final VoidCallback? onTap;

  const StatusTag({
    super.key,
    this.onTap,
    this.matchStatus,
    this.tournamentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (matchStatus == null && tournamentStatus == null) {
      return const SizedBox();
    }
    return OnTapScale(
      onTap: onTap,
      enabled: onTap != null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: matchStatus?.getColor(context) ??
              tournamentStatus?.getColor(context),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            if (onTap != null) ...[
              matchStatus == MatchStatus.running ||
                      tournamentStatus == TournamentStatus.running
                  ? Icon(
                      CupertinoIcons.play,
                      size: 16,
                      color: context.colorScheme.onPrimary,
                    )
                  : SvgPicture.asset(
                      Assets.images.icEdit,
                      height: 16,
                      width: 16,
                      colorFilter: ColorFilter.mode(
                          context.colorScheme.onPrimary, BlendMode.srcIn),
                    ),
              const SizedBox(width: 2)
            ],
            Text(
              matchStatus?.getString(context) ??
                  tournamentStatus?.getString(context) ??
                  '',
              style: AppTextStyle.caption
                  .copyWith(color: context.colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
