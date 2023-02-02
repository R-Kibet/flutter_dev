import 'package:flutter/cupertino.dart';
import 'package:trial/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "You can't share an empty note",
    optionBuilder: () => {
      "OK" : null,
    },
  );
}
