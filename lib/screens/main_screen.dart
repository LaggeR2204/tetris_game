import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/pixel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int score = 0;

  final int columnLength = 15;

  static List<List<int>> peaces = [
    [24, 25, 34, 35],
    [14, 24, 34, 35],
    [15, 25, 34, 35],
    [4, 14, 24, 34],
    [14, 24, 25, 35],
    [15, 25, 24, 34],
    [24, 25, 26, 35]
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
  int currentPeaceCenter = 0;
  Color currentColor = Colors.black;

  List<int> listPixelInBoard = [];
  List<Color> listPixelColorInBoard = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < (columnLength + 4) * 10; i++) {
      listPixelColorInBoard.add(Colors.black);
    }
    _playTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _peaceFallDown();
    });
    _playTimer.cancel();
    _fasterPlayTimer =
        Timer.periodic(const Duration(microseconds: 100), (Timer timer) {
      _peaceFallDown();
    });
    _fasterPlayTimer.cancel();
  }

  final _rand = Random();

  bool isPlaying = false;

  late Timer _playTimer;
  late Timer _fasterPlayTimer;

  void _startTimer() {
    _addNewPeace();
    _playTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _peaceFallDown();
    });
  }

  void _startFasterTimer() {
    _fasterPlayTimer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      _peaceFallDown();
    });
  }

  @override
  void dispose() {
    _playTimer.cancel();
    _fasterPlayTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Column(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildGrid(context, 10, columnLength),
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
                        if (isPlaying && !_fasterPlayTimer.isActive) {
                          _startFasterTimer();
                        }
                      },
                      child: const CustomButton(
                        child: Icon(
                          Icons.arrow_drop_down,
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
                          _transform();
                        }
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
        children: [..._buildRows(context, rowLength, i + 4)],
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
        color: listPixelInBoard.contains(pixelIndex)
            ? listPixelColorInBoard[pixelIndex]
            : (currentPeace.contains(pixelIndex) ? currentColor : Colors.black),
        // child: Text(pixelIndex.toString()),
      )));
    }
    return listRow;
  }

  _addNewPeace() {
    int randPeace = _rand.nextInt(7);
    setState(() {
      currentPeace = peaces[randPeace];
      currentColor = peaceColors[randPeace];
      currentPeaceCenter = currentPeace[1];
    });
  }

  _peaceFallDown() {
    List<int> tempNextPeacePos = currentPeace.map((e) => e + 10).toList();

    if (tempNextPeacePos
            .map((e) => listPixelInBoard.contains(e))
            .toList()
            .contains(true) ||
        tempNextPeacePos.last >= 10 * (columnLength + 4)) {
      listPixelInBoard.addAll(currentPeace);
      _clearWonRow();
      _updateColors();
      _fasterPlayTimer.cancel();
      if (_checkIsLose()) {
        _playOrReset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'You lose!!! Your score: $score',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
        ));
      } else {
        _addNewPeace();
      }
    } else {
      setState(() {
        currentPeace = currentPeace.map((e) => e + 10).toList();
        currentPeaceCenter += 10;
      });
    }
  }

  _clearWonRow() {
    for (var i = columnLength + 4 - 1; i >= 0; i--) {
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
        List<int> newPixelList = [];
        for (var item in listPixelInBoard) {
          if (item < i * 10) {
            newPixelList.add(item + 10);
            listPixelColorInBoard[item + 10] = listPixelColorInBoard[item];
          } else {
            newPixelList.add(item);
          }
        }
        setState(() {
          score++;
          listPixelInBoard = newPixelList;
          _updateColors();
        });
        _clearWonRow();
      }
    }
  }

  _updateColors() {
    for (var i = 0; i < (columnLength + 4) * 10; i++) {
      if (listPixelInBoard.contains(i)) {
        if (listPixelColorInBoard[i] == Colors.black) {
          setState(() {
            listPixelColorInBoard[i] = currentColor;
          });
        }
      } else {
        setState(() {
          listPixelColorInBoard[i] = Colors.black;
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
        currentPeaceCenter -= 1;
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
        currentPeaceCenter += 1;
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
        _updateColors();
        score = 0;
      });
    } else {
      setState(() {
        score = 0;
        isPlaying = true;
      });
      _startTimer();
    }
  }

  _transform() {
    if (_checkSquareAroundCenter(currentPeaceCenter)) {
      List<int> newPixels = [currentPeaceCenter];
      if (currentPeace.contains(currentPeaceCenter - 11)) {
        newPixels.add(currentPeaceCenter - 9);
      }
      if (currentPeace.contains(currentPeaceCenter - 10)) {
        newPixels.add(currentPeaceCenter + 1);
      }
      if (currentPeace.contains(currentPeaceCenter - 9)) {
        newPixels.add(currentPeaceCenter + 11);
      }
      if (currentPeace.contains(currentPeaceCenter - 1)) {
        newPixels.add(currentPeaceCenter - 10);
      }
      if (currentPeace.contains(currentPeaceCenter + 1)) {
        newPixels.add(currentPeaceCenter + 10);
      }
      if (currentPeace.contains(currentPeaceCenter + 9)) {
        newPixels.add(currentPeaceCenter - 11);
      }
      if (currentPeace.contains(currentPeaceCenter + 10)) {
        newPixels.add(currentPeaceCenter - 1);
      }
      if (currentPeace.contains(currentPeaceCenter + 11)) {
        newPixels.add(currentPeaceCenter + 9);
      }

      newPixels.sort();
      print(currentPeace);
      print(newPixels);
      setState(() {
        currentPeace = newPixels;
      });
    }
  }

  bool _checkSquareAroundCenter(int center) {
    if (listEquals(currentPeace.map((e) => e - currentPeace[0]).toList(),
        [0, 1, 10, 11])) {
      return false;
    }
    if (listEquals(currentPeace.map((e) => e - currentPeace[0]).toList(),
            [0, 1, 2, 3]) ||
        listEquals(currentPeace.map((e) => e - currentPeace[0]).toList(),
            [0, 10, 20, 30])) {
      // print(_checkSquareAroundCenterIPeace(center));
      return false;
    }
    List<int> temp = listPixelInBoard;
    temp.remove(currentPeace);
    if (temp.contains(center - 11) ||
        temp.contains(center - 1) ||
        temp.contains(center + 9) ||
        currentPeaceCenter % 10 == 0) {
      _moveRight();
      if (center == currentPeaceCenter) {
        return false;
      }
      _checkSquareAroundCenter(center);
    }
    if (temp.contains(center - 9) ||
        temp.contains(center + 1) ||
        temp.contains(center + 11) ||
        currentPeaceCenter % 10 == 9) {
      _moveLeft();
      if (center == currentPeaceCenter) {
        return false;
      }
      _checkSquareAroundCenter(center);
    }

    return true;
  }

  // bool _checkSquareAroundCenterIPeace(int center) {
  //   List<List<int>> square = [];

  //   if (center % 10 == 0) {
  //     _moveRight();
  //     if (center == currentPeaceCenter) {
  //       return false;
  //     }
  //     _checkSquareAroundCenterIPeace(center);
  //   }
  //   if (center % 10 == 9 || center % 10 == 8) {
  //     _moveLeft();
  //     if (center == currentPeaceCenter) {
  //       return false;
  //     }
  //     _checkSquareAroundCenterIPeace(center);
  //   }

  //   for (var i = 0; i < 4; i++) {
  //     for (var j = 0; j < 4; j++) {
  //       square[i][j] = center
  //     }
  //   }

  //   // if (listEquals(
  //   //     currentPeace.map((e) => e - currentPeace[0]).toList(), [0, 1, 2, 3])) {
  //   //   if (currentPeace[1] == currentPeaceCenter) {
  //   //     // 0 1x 2 3
  //   //     List<int> temp = listPixelInBoard;
  //   //     temp.remove(currentPeace);
  //   //     if (temp.contains(center + 10) ||
  //   //         temp.contains(center + 11) ||
  //   //         temp.contains(center + 12) ||
  //   //         temp.contains(center + 9) ||
  //   //         temp.contains(center - 1) ||
  //   //         temp.contains(center + 1) ||
  //   //         temp.contains(center + 2) ||
  //   //         temp.contains(center - 11) ||
  //   //         temp.contains(center - 8) ||
  //   //         temp.contains(center - 10) ||
  //   //         temp.contains(center - 9) ||
  //   //         temp.contains(center - 21) ||
  //   //         temp.contains(center - 18) ||
  //   //         temp.contains(center - 20) ||
  //   //         temp.contains(center - 19)) {
  //   //       return false;
  //   //     }
  //   //     return true;
  //   //   } else {
  //   //     // 0 1 2x 3
  //   //     List<int> temp = listPixelInBoard;
  //   //     temp.remove(currentPeace);
  //   //     if (temp.contains(center + 10) ||
  //   //         temp.contains(center + 11) ||
  //   //         temp.contains(center + 8) ||
  //   //         temp.contains(center + 9) ||
  //   //         temp.contains(center - 1) ||
  //   //         temp.contains(center + 1) ||
  //   //         temp.contains(center - 2) ||
  //   //         temp.contains(center - 11) ||
  //   //         temp.contains(center - 12) ||
  //   //         temp.contains(center - 10) ||
  //   //         temp.contains(center - 9) ||
  //   //         temp.contains(center + 20) ||
  //   //         temp.contains(center + 21) ||
  //   //         temp.contains(center + 19) ||
  //   //         temp.contains(center + 18)) {
  //   //       return false;
  //   //     }
  //   //     return true;
  //   //   }
  //   // } else {
  //   //   if (currentPeace[1] == currentPeaceCenter) {
  //   //     // 0 10x 20 30
  //   //     List<int> temp = listPixelInBoard;
  //   //     temp.remove(currentPeace);
  //   //     if (temp.contains(center - 11) ||
  //   //         temp.contains(center - 1) ||
  //   //         temp.contains(center + 9) ||
  //   //         temp.contains(center + 19) ||
  //   //         currentPeaceCenter % 10 == 0) {
  //   //       _moveRight();
  //   //       if (center == currentPeaceCenter) {
  //   //         return false;
  //   //       }
  //   //       _checkSquareAroundCenterIPeace(center);
  //   //     }
  //   //     if (temp.contains(center - 9) ||
  //   //         temp.contains(center + 1) ||
  //   //         temp.contains(center + 11) ||
  //   //         temp.contains(center + 21) ||
  //   //         temp.contains(center - 8) ||
  //   //         temp.contains(center + 2) ||
  //   //         temp.contains(center + 12) ||
  //   //         temp.contains(center + 22) ||
  //   //         currentPeaceCenter % 10 == 9 ||
  //   //         currentPeaceCenter % 10 == 8) {
  //   //       _moveLeft();
  //   //       if (center == currentPeaceCenter) {
  //   //         return false;
  //   //       }
  //   //       _checkSquareAroundCenterIPeace(center);
  //   //     }
  //   //     return true;
  //   //   } else {
  //   //     // 0 10 20x 30
  //   //     List<int> temp = listPixelInBoard;
  //   //     temp.remove(currentPeace);
  //   //     if (temp.contains(center - 19) ||
  //   //         temp.contains(center - 9) ||
  //   //         temp.contains(center + 1) ||
  //   //         temp.contains(center + 11) ||
  //   //         currentPeaceCenter % 10 == 9) {
  //   //       _moveLeft();
  //   //       if (center == currentPeaceCenter) {
  //   //         return false;
  //   //       }
  //   //       _checkSquareAroundCenterIPeace(center);
  //   //     }
  //   //     if (temp.contains(center - 1) ||
  //   //         temp.contains(center - 11) ||
  //   //         temp.contains(center + 9) ||
  //   //         temp.contains(center - 21) ||
  //   //         temp.contains(center - 2) ||
  //   //         temp.contains(center - 12) ||
  //   //         temp.contains(center - 22) ||
  //   //         temp.contains(center + 8) ||
  //   //         currentPeaceCenter % 10 == 0 ||
  //   //         currentPeaceCenter % 10 == 1) {
  //   //       _moveRight();
  //   //       if (center == currentPeaceCenter) {
  //   //         return false;
  //   //       }
  //   //       _checkSquareAroundCenterIPeace(center);
  //   //     }
  //   //     return true;
  //   //   }
  //   // }
  // }

  // _transformIPeace() {
  //   if (listEquals(
  //       currentPeace.map((e) => e - currentPeace[0]).toList(), [0, 1, 2, 3])) {
  //     if (currentPeace[1] == currentPeaceCenter) {
  //       // 0 1x 2 3
  //     } else {
  //       // 0 1 2x 3
  //     }
  //   } else {
  //     if (currentPeace[1] == currentPeaceCenter) {
  //       // 0 10x 20 30
  //     } else {
  //       // 0 10 20x 30
  //     }
  //   }
  // }

  _checkIsLose() {
    if (currentPeace[3] ~/ 10 == 3) {
      return true;
    }
    return false;
  }
}
