// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minesweeper/providers/start.dart';
import 'package:minesweeper/providers/end.dart';

class Cell extends ConsumerStatefulWidget {
  Cell(
      {super.key,
      required this.text,
      required this.index,
      required this.getStartedList,
      required this.reveal,
      required this.isPressed,
      required this.isFlagged,
      required this.toggleFlag,
      required this.reset});
  String text;
  final int index;
  final void Function(int index)
      getStartedList; //boolstarting= false;  if(starting==f)
  final void Function(int index) reveal;
  bool isPressed = false;
  final bool isFlagged;
  final void Function() toggleFlag;
  final void Function() reset;
  @override
  ConsumerState<Cell> createState() => _CellState();
}

class _CellState extends ConsumerState<Cell> {
  // bool pressed = false;
  bool flagged = false;
  bool allowPress = true;

  Widget? getChild() {
    if (widget.isPressed) {
   
      return Text(
        widget.text.toString(),
        style: const TextStyle(fontSize: 40),
      );
    } else if (widget.isFlagged) {
      return Image.asset('assets/images/flag.png');
    } else {
      return null;
    }
  }

  // bool allowChange = flagged;

  @override
  Widget build(BuildContext context) {
    final checkingState = ref.watch(getStartedProvider.notifier).getState();
    final chechingPressed = ref.watch(getEndedProvider.notifier).getPressed();
    return InkWell(
        onLongPress: widget.toggleFlag,
        onTap: !widget.isPressed && !widget.isFlagged
            ? () {
                if (int.tryParse(widget.text) == -1) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('you lost'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('ok'))
                        ],
                      );
                    },
                  );
                  widget.reset();
                }
                if (!checkingState) {
                  ref.read(getStartedProvider.notifier).start();
                  widget.getStartedList(widget.index);
                }
                widget.reveal(
                  widget.index,
                );
              
                  widget.isPressed = true;
                   ref.read(getEndedProvider.notifier).end(); 
                    ref.read(getEndedProvider.notifier).end1(); 
                     setState(() {
                });
              
                
                if (chechingPressed >= 65) {//todo n.o cells-n.o mines-1
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('you win'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('ok'))
                        ],
                          
                      );
                    },
                  );  widget.reset();
                }
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
              color: !widget.isPressed ? Colors.grey[600] : Colors.grey,
              boxShadow: [
                if (!widget.isPressed && allowPress)
                  const BoxShadow(
                    blurRadius: 10,
                    color: Color.fromARGB(255, 60, 60, 60),
                  )
              ]),
          child: Center(child: getChild()),
        ));
  }
}
