import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/state/plugin_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final BuildContext context;

  AppLifecycleObserver(this.context);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final pluginState = Provider.of<PluginState>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      CommonUtils.getXRouteAndPopAll(widget: pluginState.logoutScreen);
    }
  }
}