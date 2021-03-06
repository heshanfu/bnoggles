// Copyright (c) 2018, The Bnoggles Team.
// Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:bnoggles/screens/result/widgets/score.dart';
import 'package:bnoggles/utils/game_info.dart';
import 'package:bnoggles/utils/gamelogic/board.dart';
import 'package:bnoggles/utils/gamelogic/coordinate.dart';
import 'package:bnoggles/widgets/board_widget.dart';
import 'package:bnoggles/widgets/start_game_button.dart';
import 'package:flutter/material.dart';

import 'package:bnoggles/utils/gamelogic/solution.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({@required this.gameInfo});
  final GameInfo gameInfo;

  @override
  State<StatefulWidget> createState() => ResultScreenState(gameInfo: gameInfo);
}

class ResultScreenState extends State<ResultScreen> {
  ResultScreenState({@required this.gameInfo});

  final GameInfo gameInfo;
  List<Coordinate> highlightedTiles = [];

  @override
  Widget build(BuildContext context) {
    Solution solution = gameInfo.solution;
    UserAnswer userAnswer = gameInfo.userAnswer.value;
    Board board = gameInfo.board;

    double mediaWidth = MediaQuery.of(context).size.width;
    double wordViewWidth = mediaWidth / 6;
    double secondColumnWidth = mediaWidth - wordViewWidth;
    double cellWidth = secondColumnWidth / board.width;

    Map<String, List<Coordinate>> optionPerWord = Map.fromIterable(
        solution.chains,
        key: (dynamic chain) => (chain as Chain).text,
        value: (dynamic chain) => (chain as Chain).chain);

    List<Widget> tiles = solution
        .uniqueWordsSorted()
        .map(
          (word) => GestureDetector(
                child: Container(
                  margin: EdgeInsets.fromLTRB(3.0, 5.0, 3.0, 5.0),
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: userAnswer.contains(word)
                        ? Colors.green
                        : Colors.lightBlueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text(
                    word.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.0,
                      color: userAnswer.contains(word)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    highlightedTiles = optionPerWord[word];
                  });
                },
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Bnoggles"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            width: wordViewWidth,
            child: ListView(children: tiles),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                    child: Center(
                        child: ScoreOverview(
                  scores: gameInfo.scoreSheet,
                  fontSize: secondColumnWidth / 20,
                ))),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: BoardWidget(
                    selectedPositions: highlightedTiles,
                    board: board,
                    centeredCharacter: CenteredCharacter(cellWidth),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: "settings",
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName(Navigator.defaultRouteName),
                          );
                        },
                        child: Icon(Icons.settings),
                      ),
                      Container(
                        width: 20.0,
                      ),
                      StartGameButton(
                        parameterProvider: () => gameInfo.parameters,
                        replaceScreen: true,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
