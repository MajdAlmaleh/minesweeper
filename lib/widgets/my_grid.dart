// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/providers/end.dart';
import 'package:minesweeper/widgets/cell.dart';
import 'package:minesweeper/providers/start.dart';

class MyGrid extends ConsumerStatefulWidget {
  const MyGrid({super.key});

  @override
  ConsumerState<MyGrid> createState() => _MyGridState();
}

class _MyGridState extends ConsumerState<MyGrid> {
  final crossAxisCount = 9;
  final numberOfItems = 81;
  var itemsList = [];

  List<bool> pressedList = List<bool>.filled(81, false);
  List<bool> flagged = List<bool>.filled(81, false);
  bool triggerd = true;
  bool pressed = false;

  void reset() {
    ref.read(getStartedProvider.notifier).reset();
    ref.read(getEndedProvider.notifier).reset();
    pressedList = List<bool>.filled(81, false);
    flagged = List<bool>.filled(81, false);
    triggerd = true;
    pressed = false;

    setState(() {});
  }

  void reveal(int index) {
    // If the cell is already revealed or is a mine, return
    if (pressedList[index] || itemsList[index] == -1 || flagged[index]) {
      return;
    }

    // Reveal the cell
    pressedList[index] = true;
    ref.read(getEndedProvider.notifier).end();
    final chechingPressed = ref.watch(getEndedProvider.notifier).getPressed();
  

    // If the cell is a zero (no mines around), reveal the surrounding cells
    if (itemsList[index] == 0) {
      List<int> surroundingCells = getSurroundingCells(index);
      for (int i in surroundingCells) {
        reveal(i);
      }
    }

    setState(() {});
  }

  List<int> getSurroundingCells(int index) {
    List<int> surroundingCells = [];

    // Calculate the row and column of the cell
    int row = index ~/ crossAxisCount;
    int col = index % crossAxisCount;

    // Calculate the total number of rows (or columns) in the grid
    int gridSize = numberOfItems ~/ crossAxisCount;

    // Loop over each of the surrounding cells
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        // Skip the cell itself
        if (i == 0 && j == 0) continue;

        // Calculate the row and column of the surrounding cell
        int surroundingRow = row + i;
        int surroundingCol = col + j;

        // Check if the surrounding cell is within the grid
        if (surroundingRow >= 0 &&
            surroundingRow < gridSize &&
            surroundingCol >= 0 &&
            surroundingCol < crossAxisCount) {
          // Calculate the index of the surrounding cell and add it to the list
          int surroundingIndex =
              surroundingRow * crossAxisCount + surroundingCol;
          surroundingCells.add(surroundingIndex);
        }
      }
    }

    return surroundingCells;
  }

  List getList(int index) {
    List<int> surroundingCells = getSurroundingCells(index);
    List<int> total = List<int>.filled(numberOfItems, 0, growable: false);
    Set<int> minesPlaces = {};
    while (minesPlaces.length < 15) {
      //todo number of mines
      int randomNumber;
      do {
        randomNumber = Random().nextInt(numberOfItems);
      } while (randomNumber == index ||
          surroundingCells.contains(randomNumber)); //todo first pressed index
      minesPlaces.add(randomNumber);
    }
    List<int> minesPlacesList = minesPlaces.toList();
    for (int i = 0; i < 15; i++) {
      //todo n.o number of mines
      total[minesPlacesList[i]] = -1;
    }

    for (int i = 0; i < total.length / crossAxisCount; i++) {
      for (int j = 0; j < crossAxisCount; j++) {
        if (total[crossAxisCount * i + j] == -1) continue;

        // Check previous row
        if (i > 0) {
          if (j > 0 && total[crossAxisCount * (i - 1) + j - 1] == -1)
            total[crossAxisCount * i + j]++;
          if (total[crossAxisCount * (i - 1) + j] == -1)
            total[crossAxisCount * i + j]++;
          if (j < crossAxisCount - 1 &&
              total[crossAxisCount * (i - 1) + j + 1] == -1)
            total[crossAxisCount * i + j]++;
        }

        // Check current row
        if (j > 0 && total[crossAxisCount * i + j - 1] == -1)
          total[crossAxisCount * i + j]++;
        if (j < crossAxisCount - 1 && total[crossAxisCount * i + j + 1] == -1)
          total[crossAxisCount * i + j]++;

        // Check next row
        if (i < total.length / crossAxisCount - 1) {
          if (j > 0 && total[crossAxisCount * (i + 1) + j - 1] == -1)
            total[crossAxisCount * i + j]++;
          if (total[crossAxisCount * (i + 1) + j] == -1)
            total[crossAxisCount * i + j]++;
          if (j < crossAxisCount - 1 &&
              total[crossAxisCount * (i + 1) + j + 1] == -1)
            total[crossAxisCount * i + j]++;
        }
      }
    }
    return total;
  }

  void getStarted(int startingIndex) {
    itemsList = getList(startingIndex);
    pressed = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 26, 25, 25),
        body: GridView.builder(
            itemCount: numberOfItems,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                crossAxisCount: crossAxisCount),
            itemBuilder: (context, index) {
              return Cell(
                  reveal: reveal,
                  text: pressed ? itemsList[index].toString() : '',
                  index: index,
                  isPressed: pressedList[index],
                  getStartedList: getStarted,
                  isFlagged: flagged[index],
                  reset: reset,
                  toggleFlag: () {
                    setState(() {
                      flagged[index] = !flagged[index];
                    });
                  });
            }));
  }
}
