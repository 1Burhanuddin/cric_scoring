import 'package:cricheros_data/api/user/user_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cricheros/components/image_avatar.dart';
import 'package:cricheros/domain/extensions/context_extensions.dart';
import 'package:cricheros/domain/extensions/enum_extensions.dart';
import 'package:cricheros/domain/formatter/string_formatter.dart';
import 'package:cricheros_style/extensions/context_extensions.dart';
import 'package:cricheros_style/text/app_text_style.dart';

class UserDetailCell extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool showPhoneNumber;

  const UserDetailCell({
    super.key,
    required this.user,
    this.onTap,
    this.trailing,
    this.padding,
    this.showPhoneNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: user.isActive ? onTap : null,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          children: [
            ImageAvatar(
              initial: user.nameInitial,
              imageUrl: user.profile_img_url,
              size: 40,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? context.l10n.common_anonymous_title,
                    style: AppTextStyle.subtitle2
                        .copyWith(color: context.colorScheme.textPrimary),
                  ),
                  Text(
                      user.player_role != null
                          ? user.player_role!.getString(context)
                          : context.l10n.common_not_specified_title,
                      style: AppTextStyle.caption
                          .copyWith(color: context.colorScheme.textDisabled)),
                  if (user.phone != null && showPhoneNumber) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.phone
                          .format(context, StringFormats.obscurePhoneNumber),
                      style: AppTextStyle.caption
                          .copyWith(color: context.colorScheme.textDisabled),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? const SizedBox()
          ],
        ),
      ),
    );
  }
}
