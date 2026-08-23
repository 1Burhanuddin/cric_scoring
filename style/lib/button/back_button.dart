import 'package:flutter/cupertino.dart';
import 'package:cricheros_style/button/action_button.dart';
import 'package:cricheros_style/extensions/context_extensions.dart';

// iOS-style chevron on every platform (not just iOS) — matches the
// leading widget AppPage now generates for its Material branch, see
// khelo/lib/components/app_page.dart.
Widget backButton(
  BuildContext context, {
  VoidCallback? onPressed,
}) {
  return actionButton(
    context,
    onPressed: onPressed,
    icon: Icon(
      CupertinoIcons.back,
      color: context.colorScheme.textPrimary,
    ),
  );
}
