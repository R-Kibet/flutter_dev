import 'package:flutter/cupertino.dart';

typedef CloseLoadingScreem = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreem close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
