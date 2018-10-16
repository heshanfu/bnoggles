import 'package:bnoggles/screens/game/widgets/game_clock.dart';
import 'package:bnoggles/screens/game/widgets/game_word_count_row.dart';
import 'package:bnoggles/screens/result/result_screen.dart';
import 'package:bnoggles/utils/solution.dart';
import 'package:bnoggles/screens/game/widgets/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GameProgress extends StatelessWidget {
  final AnimationController _controller;
  final int _startValue;

  GameProgress(this._controller, this._startValue);

  @override
  build(BuildContext context) {
    var showResultScreen = () {
      GameInfo gameInfo = Provider.of(context);
      Solution solution = gameInfo.solution;
      UserAnswer userAnswer = gameInfo.userAnswer.value;
      gameInfo.gameOngoing = false;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultScreen(solution, userAnswer)));
    };

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 350.0, height: 100.0, child: WordCountOverview()),
      Expanded(
          child: Container(
              height: 100.0,
              child: Clock(showResultScreen, _controller, _startValue))),
      IconButton(
        icon: Icon(Icons.stop),
        onPressed: () {
          _controller.stop();
          showResultScreen();
        },
      )
    ]);
  }
}
