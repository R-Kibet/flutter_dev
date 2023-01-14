import 'package:flutter/cupertino.dart';
import 'package:trial/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: "An error occurred",
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
