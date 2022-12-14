import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///  Empêche l'application de passer en mode paysage
void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

mixin PortraitModeMixin on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    return Container();
  }
}
