import 'package:flutter/material.dart';
import 'package:cricheros_style/button/action_button.dart';
import 'package:cricheros_style/extensions/context_extensions.dart';

Widget backButton(
  BuildContext context, {
  VoidCallback? onPressed,
}) {
  return actionButton(
    context,
    onPressed: onPressed,
    icon: Icon(
      Icons.arrow_back,
      color: context.colorScheme.textPrimary,
    ),
  );
}
