import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_solver_backtracking/custom_numeric_formatter.dart';

void main() {
  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<List<int>> board = [
    [7, 8, 0, 4, 0, 0, 1, 2, 0],
    [6, 0, 0, 0, 7, 5, 0, 0, 9],
    [0, 0, 0, 6, 0, 1, 0, 7, 8],
    [0, 0, 7, 0, 4, 0, 2, 6, 0],
    [0, 0, 1, 0, 5, 0, 9, 3, 0],
    [9, 0, 4, 0, 6, 0, 0, 0, 5],
    [0, 7, 0, 3, 0, 0, 0, 1, 2],
    [1, 2, 0, 0, 0, 7, 4, 0, 0],
    [0, 4, 9, 2, 0, 6, 0, 0, 7]
  ];
  static final ScrollController _gridViewController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Solver using backtracking'),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                board = [
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0, 0],
                ];
              });
            },
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 750,
            width: 750,
            child: Stack(
              children: [
                const Positioned(
                  top: 247.5,
                  left: 30,
                  right: 30,
                  child: Divider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                ),
                const Positioned(
                  top: 247.5 + 240,
                  left: 30,
                  right: 30,
                  child: Divider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                ),
                const Positioned(
                  left: 247.5 + 240,
                  top: 30,
                  bottom: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                ),
                const Positioned(
                  left: 247.5,
                  top: 30,
                  bottom: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.all(30),
                  controller: _gridViewController,
                  itemCount: 81,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    mainAxisSpacing: 30,
                    crossAxisSpacing: 30,
                    mainAxisExtent: 50,
                  ),
                  itemBuilder: (context, index) {
                    int xIndex = index ~/ 9;
                    int yIndex = index % 9;

                    int initialIntValue = board[xIndex][yIndex];

                    return SizedBox(
                      height: 50,
                      width: 50,
                      child: TextFormField(
                        key: UniqueKey(),
                        initialValue: initialIntValue == 0 ? '' : initialIntValue.toString(),
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp("[1-9]"), allow: true),
                          CustomNumericFormatter(1, 9),
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                        onChanged: (input) {
                          if (input.isNotEmpty) {
                            board[xIndex][yIndex] = int.parse(input);
                          } else {
                            board[xIndex][yIndex] = 0;
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //print(board);
              // if (solve(board)) {
              solve(board);
              setState(() {});
              //  print(board);
              // }
            },
            child: const Text('Solve'),
          ),
        ],
      ),
    );
  }
}

List<int>? checkEmpty(List<List<int>> board) {
  List<int>? emptySquarePos;

  outerLoop:
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (board[i][j] == 0) {
        emptySquarePos = [i, j];
        break outerLoop;
      } else {
        emptySquarePos = null;
      }
    }
  }
  return emptySquarePos;
}

bool checkValid(List<List<int>> board, int input, List<int> pos) {
//check for row
  for (int i = 0; i < 9; i++) {
    if (board[pos[0]][i] == input && pos[1] != i) {
      return false;
    }
  }

  //check column
  for (int i = 0; i < 9; i++) {
    if (board[i][pos[1]] == input && pos[0] != i) {
      return false;
    }
  }

  //check 3x3 grid
  int xBox = pos[1] ~/ 3;
  int yBox = pos[0] ~/ 3;
  for (int i = yBox * 3; i < (yBox * 3) + 3; i++) {
    for (int j = xBox * 3; j < (xBox * 3) + 3; j++) {
      if (board[i][j] == input && i != pos[0] && j != pos[1]) {
        return false;
      }
    }
  }
  return true;
}

solve(List<List<int>> board) {
  List<int>? pos = checkEmpty(board);
  if (pos == null) {
    return true;
  }
  for (int i = 1; i < 10; i++) {
    if (checkValid(board, i, pos)) {
      board[pos[0]][pos[1]] = i;
      //* if board is valid, recurse using new board
      if (solve(board)) {
        return true;
      }
      //* if board is not valid, backtrack
      board[pos[0]][pos[1]] = 0;
    }
  }
  return false;
}
