import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/pixel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int columnLength = 10;

  static List<List<int>> peaces = [
    [4, 5, 14, 15],
    [4, 14, 24, 25],
    [5, 15, 24, 25],
    [4, 14, 24, 34],
    [4, 14, 15, 25],
    [5, 15, 14, 24],
    [4, 5, 6, 15]
  ];

  static List<Color> peaceColors = [
    Colors.red,
    Colors.yellow,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.white
  ];

  List<int> currentPeace = [];

  List<int> listPixelInBoard = [];

  final _rand = Random();

  bool isPlaying = false;

  late Timer _playTimer;

  void _startTimer() {
    _addNewPeace();
    _playTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _peaceFallDown();
    });
  }

  @override
  void dispose() {
    _playTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildGrid(context, 10, 10),
          )),
          SizedBox(
            height: 100.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        _moveLeft();
                      }
                    },
                    child: const CustomButton(
                      child: Icon(
                        Icons.arrow_left,
                        color: Colors.deepPurple,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        _moveRight();
                      }
                    },
                    child: const CustomButton(
                      child: Icon(
                        Icons.arrow_right,
                        color: Colors.deepPurple,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _playOrReset();
                    },
                    child: CustomButton(
                      child: Text(
                        isPlaying ? 'RESET' : 'PLAY',
                        style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isPlaying) {}
                    },
                    child: const CustomButton(
                      child: Icon(
                        Icons.restart_alt,
                        color: Colors.deepPurple,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildGrid(BuildContext context, int rowLength, int columnLength) {
    return Column(
      children: [..._buildColumns(context, rowLength, columnLength)],
    );
  }

  _buildColumns(BuildContext context, int rowLength, int columnLength) {
    List<Widget> listColumn = [];
    for (var i = 0; i < columnLength; i++) {
      listColumn.add(Expanded(
          child: Row(
        children: [..._buildRows(context, rowLength, i)],
      )));
    }
    return listColumn;
  }

  _buildRows(BuildContext context, int rowLength, int columnIndex) {
    List<Widget> listRow = [];
    for (var i = 0; i < rowLength; i++) {
      int pixelIndex = 10 * columnIndex + i;
      listRow.add(Expanded(
          child: Pixel(
        color: (listPixelInBoard.contains(pixelIndex) ||
                currentPeace.contains(pixelIndex))
            ? Colors.deepPurple
            : Colors.black,
        // child: Text(pixelIndex.toString()),
      )));
    }
    return listRow;
  }

  _addNewPeace() {
    setState(() {
      currentPeace = peaces[_rand.nextInt(7)];
    });
  }

  _peaceFallDown() {
    List<int> tempNextPeacePos = currentPeace.map((e) => e + 10).toList();

    if (tempNextPeacePos
            .map((e) => listPixelInBoard.contains(e))
            .toList()
            .contains(true) ||
        tempNextPeacePos.last >= 10 * columnLength) {
      listPixelInBoard.addAll(currentPeace);
      _addNewPeace();
    } else {
      setState(() {
        currentPeace = currentPeace.map((e) => e + 10).toList();
      });
    }
  }

  _clearWonRow() {
    //temp
    for (var i = columnLength - 1; i >= 0; i++) {
      List<bool> rowCheck = [];
      for (var j = 0; j < 10; j++) {
        if (listPixelInBoard.contains(10 * i + j)) {
          rowCheck.add(true);
        } else {
          rowCheck.add(false);
        }
      }
      if (!rowCheck.contains(false)) {
        for (var k = 0; k < 10; k++) {
          setState(() {
            listPixelInBoard.remove(10 * i + k);
          });
        }
        setState(() {
          for (var item in listPixelInBoard) {
            if (item < i * 10) {
              item + 10;
            }
          }
        });
      }
    }
  }

  _moveLeft() {
    List<int> tempNextPeacePos = currentPeace.map((e) => e - 1).toList();

    if (tempNextPeacePos
            .map((e) => listPixelInBoard.contains(e))
            .toList()
            .contains(true) ||
        currentPeace.map((e) => e % 10).toList().contains(0)) {
    } else {
      setState(() {
        currentPeace = currentPeace.map((e) => e - 1).toList();
      });
    }
  }

  _moveRight() {
    List<int> tempNextPeacePos = currentPeace.map((e) => e + 1).toList();

    if (tempNextPeacePos
            .map((e) => listPixelInBoard.contains(e))
            .toList()
            .contains(true) ||
        currentPeace.map((e) => e % 10).toList().contains(9)) {
    } else {
      setState(() {
        currentPeace = currentPeace.map((e) => e + 1).toList();
      });
    }
  }

  _playOrReset() {
    if (isPlaying) {
      setState(() {
        _playTimer.cancel();
        isPlaying = false;
        currentPeace = [];
        listPixelInBoard = [];
      });
    } else {
      setState(() {
        isPlaying = true;
      });
      _startTimer();
    }
  }
}
