import 'package:flutter/cupertino.dart';

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modelRoute = ModalRoute.of(this);
    if (modelRoute != null){
      final args = modelRoute.settings.arguments;
      if (args != null && args is T){
        return args as T;
      }
    }
    return null;
  }
}