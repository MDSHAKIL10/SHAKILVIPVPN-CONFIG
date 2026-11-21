import 'package:flutter/material.dart';

/// The Android client uses config_maker.html as its publisher. This file is a
/// small Flutter launcher retained for existing builds; it intentionally does
/// not collect or store a GitHub token.
void main() => runApp(const ConfigPublisherInfo());

class ConfigPublisherInfo extends StatelessWidget {
  const ConfigPublisherInfo({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SHAKILVIPVPN Config Publisher',
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          appBar: AppBar(title: const Text('Configuration Publisher')),
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: SelectableText(
              'Use config_maker.html in the SHAKILVIPVPN-CONFIG repository to create and publish servers.json. '
              'The Android application fetches that published configuration automatically and on manual refresh. '
              'Do not publish account credentials or private keys.',
            ),
          ),
        ),
      );
}
