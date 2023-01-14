import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<bool> showDeleteDialogue(BuildContext context)  {
  return showGenericDialog<bool>(
    context: context,
    title: "Delete",
    content: "Are you sure you wan to delete this item",
    optionBuilder: () => {
      "Cancel" : false,
      "Yes": true,
    },
  ).then(
        (value) => value ?? false,
  );
}
