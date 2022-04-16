import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_bsp/db/CsvService.dart';
import 'package:open_bsp/db/QuestionDb.dart';
import 'package:open_bsp/models/category.dart';
import 'package:settings_ui/settings_ui.dart';

import '../models/question.dart';

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
          SettingsSection(
            title: Text('Database'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.code),
                title: Text('Insert dog'),
                onPressed: (value) {
                  debugFunction();
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Quiz'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                title: Text('Schnelle Antwort'),
                description: Text('Wechselt direkt zur nächsten Frage nach Antwort.'),
                initialValue: false,
                onToggle: (bool value) {},
                onPressed: (value) {
                  debugFunction();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void fastAnswerMode() {


  }

  void debugFunction() async {
    print("Debug Function pressed");
    // QuestionDb questionDb = QuestionDb.instance;
    // questionDb.categoryTable();

    CsvService csvService = new CsvService();
    List<Category> categories =
        await csvService.mapCsvToCategories('assets/misc/test.csv');
    csvService.saveCategoriesToDatabase(categories);

    //List<Question> questions = await csvService.mapCsvToQuestions('assets/misc/questions.csv');
    //csvService.saveQuestionsToDatabase(questions);
    //print("Question: " + questions[0].question);
  }
}
