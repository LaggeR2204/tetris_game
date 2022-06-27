import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/pixel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
                    onTap: () {},
                    child: const CustomButton(
                      child: Icon(Icons.arrow_left),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: const CustomButton(
                      child: Icon(Icons.arrow_right),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: const CustomButton(
                      child: Text('PLAY'),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: const CustomButton(
                      child: Icon(Icons.restart_alt),
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
      listRow.add(Expanded(
          child: Pixel(
        color: Colors.black,
        child: Text((10 * columnIndex + i).toString()),
      )));
    }
    return listRow;
  }
}
