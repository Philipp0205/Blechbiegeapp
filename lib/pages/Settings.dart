import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/db/CsvService.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Debugging'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.code),
                title: Text('Debug function'),
                onPressed: (value) {
			debugFunction();
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void debugFunction() {
	  print("Debug Function pressed");
	  CsvService csvService = new CsvService();
	  csvService.loadCsv();
  }
}
