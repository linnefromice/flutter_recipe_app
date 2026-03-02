import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // ignore: do_not_use_environment
  const isRunningInCi = bool.fromEnvironment('CI', defaultValue: false);

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: !isRunningInCi,
      ),
      ciGoldensConfig: const CiGoldensConfig(enabled: true),
    ),
    run: testMain,
  );
}
