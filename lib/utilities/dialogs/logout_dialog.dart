
import 'package:flutter/material.dart';
import 'package:trial/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context)  {
  return showGenericDialog<bool>(
    context: context,
    title: "Log out",
    content: "Are you sure you wan to log out",
    optionBuilder: () => {
      "Cancel" : false,
      "Log out": true,
    },
  ).then(
          (value) => value ?? false,
  );
}
