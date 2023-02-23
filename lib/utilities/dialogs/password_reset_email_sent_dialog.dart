import 'package:flutter/cupertino.dart';
import 'package:trial/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: "Password Reset",
      content: "Check your email for reset link",
      optionBuilder: () => {
        'OK': null,
      },
  );
}
