part of views;

class IIDXButton extends ButtonControlButton {

  IIDXButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  IIDXButtonState createState() => IIDXButtonState(this, listenable);
}

class IIDXButtonState extends ButtonControlButtonState {
  IIDXButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: button.isDown()
            ? Color(0xFF501010)
            : Color(0xFF505050),
        /*border: Border.all(
          color: Color(0xFF102050),
        ),*/
      )
    );
  }
}

class IIDXControllerView extends StatefulWidget {

  @override
  IIDXControllerViewState createState() => IIDXControllerViewState();
}

class IIDXControllerViewState extends State<IIDXControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      IIDXButton(buttonControl.notifier, "P1 Start"),
      IIDXButton(buttonControl.notifier, "EFFECT"),
      IIDXButton(buttonControl.notifier, "VEFX"),
      IIDXButton(buttonControl.notifier, "P1 1"),
      IIDXButton(buttonControl.notifier, "P1 2"),
      IIDXButton(buttonControl.notifier, "P1 3"),
      IIDXButton(buttonControl.notifier, "P1 4"),
      IIDXButton(buttonControl.notifier, "P1 5"),
      IIDXButton(buttonControl.notifier, "P1 6"),
      IIDXButton(buttonControl.notifier, "P1 7"),
      IIDXButton(buttonControl.notifier, "P1 TT+/-"),
      IIDXButton(buttonControl.notifier, "P2 Start"),
      IIDXButton(buttonControl.notifier, "EFFECT"),
      IIDXButton(buttonControl.notifier, "VEFX"),
      IIDXButton(buttonControl.notifier, "P2 1"),
      IIDXButton(buttonControl.notifier, "P2 2"),
      IIDXButton(buttonControl.notifier, "P2 3"),
      IIDXButton(buttonControl.notifier, "P2 4"),
      IIDXButton(buttonControl.notifier, "P2 5"),
      IIDXButton(buttonControl.notifier, "P2 6"),
      IIDXButton(buttonControl.notifier, "P2 7"),
      IIDXButton(buttonControl.notifier, "P2 TT+/-"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var viewCount = 4;
    var viewNo = controllerViewNo.value % viewCount;
    if (viewNo == 0) return buildLeft(context, 1);
    if (viewNo == 1) return buildTurntable(context, 1);
    if (viewNo == 2) return buildRight(context, 2);
    if (viewNo == 3) return buildTurntable(context, 2);
    return null;
  }

  Widget buildLeft(BuildContext context, int player) {
    int startIndex = player == 2 ? 11 : 0;
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 19 / 9,
            child: Container(
              /*decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF102050),
                ),
              ),*/
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: [

                      // START
                      Positioned(
                        left: areaWidth * 0.85,
                        top: areaWidth * (0.0625 + 0.125 * 0),
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaWidth * 0.1,
                          child: buttonControl.widgets[startIndex + 0],
                        )
                      ),

                      // EFFECT
                      Positioned(
                        left: areaWidth * 0.85,
                        top: areaWidth * (0.0625 + 0.125 * 1),
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaWidth * 0.1,
                          child: buttonControl.widgets[startIndex + 1],
                        )
                      ),

                      // VEFX
                      Positioned(
                        left: areaWidth * 0.85,
                        top: areaWidth * (0.0625 + 0.125 * 2),
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaWidth * 0.1,
                          child: buttonControl.widgets[startIndex + 2],
                        )
                      ),

                      // key 1
                      Positioned(
                        left: areaWidth * (0.15 + 0.175 * 0),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[startIndex + 3],
                        )
                      ),

                      // key 3
                      Positioned(
                        left: areaWidth * (0.15 + 0.175 * 1),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[startIndex + 5],
                        )
                      ),

                      // key 5
                      Positioned(
                        left: areaWidth * (0.15 + 0.175 * 2),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[startIndex + 7],
                        )
                      ),

                      // key 7
                      Positioned(
                        left: areaWidth * (0.15 + 0.175 * 3),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[startIndex + 9],
                        )
                      ),

                      // key 2
                      Positioned(
                        left: areaWidth * (0.225 + 0.175 * 0),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
                          child: buttonControl.widgets[startIndex + 4],
                        )
                      ),

                      // key 4
                      Positioned(
                        left: areaWidth * (0.225 + 0.175 * 1),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
                          child: buttonControl.widgets[startIndex + 6],
                        )
                      ),

                      // key 6
                      Positioned(
                        left: areaWidth * (0.225 + 0.175 * 2),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
                          child: buttonControl.widgets[startIndex + 8],
                        )
                      ),

                      // TT +/-
                      Positioned(
                        left: areaWidth * 0.0125,
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.115,
                          height: areaHeight * 0.95,
                          child: buttonControl.widgets[startIndex + 10],
                        )
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget buildRight(BuildContext context, int player) {
    int startIndex = player == 2 ? 11 : 0;
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 19 / 9,
            child: Container(
              /*decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF102050),
              ),
            ),*/
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: [

                      // START
                      Positioned(
                          left: areaWidth * 0.025,
                          top: areaWidth * (0.0625 + 0.125 * 0),
                          child: Container(
                            width: areaWidth * 0.1,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[startIndex + 0],
                          )
                      ),

                      // EFFECT
                      Positioned(
                          left: areaWidth * 0.025,
                          top: areaWidth * (0.0625 + 0.125 * 1),
                          child: Container(
                            width: areaWidth * 0.1,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[startIndex + 1],
                          )
                      ),

                      // VEFX
                      Positioned(
                          left: areaWidth * 0.025,
                          top: areaWidth * (0.0625 + 0.125 * 2),
                          child: Container(
                            width: areaWidth * 0.1,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[startIndex + 2],
                          )
                      ),

                      // key 1
                      Positioned(
                          left: areaWidth * (0.15 + 0.175 * 0),
                          top: areaHeight * 0.525,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.2125,
                            child: buttonControl.widgets[startIndex + 3],
                          )
                      ),

                      // key 3
                      Positioned(
                          left: areaWidth * (0.15 + 0.175 * 1),
                          top: areaHeight * 0.525,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.2125,
                            child: buttonControl.widgets[startIndex + 5],
                          )
                      ),

                      // key 5
                      Positioned(
                          left: areaWidth * (0.15 + 0.175 * 2),
                          top: areaHeight * 0.525,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.2125,
                            child: buttonControl.widgets[startIndex + 7],
                          )
                      ),

                      // key 7
                      Positioned(
                          left: areaWidth * (0.15 + 0.175 * 3),
                          top: areaHeight * 0.525,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.2125,
                            child: buttonControl.widgets[startIndex + 9],
                          )
                      ),

                      // key 2
                      Positioned(
                          left: areaWidth * (0.225 + 0.175 * 0),
                          top: areaHeight * 0.025,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.225,
                            child: buttonControl.widgets[startIndex + 4],
                          )
                      ),

                      // key 4
                      Positioned(
                          left: areaWidth * (0.225 + 0.175 * 1),
                          top: areaHeight * 0.025,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.225,
                            child: buttonControl.widgets[startIndex + 6],
                          )
                      ),

                      // key 6
                      Positioned(
                          left: areaWidth * (0.225 + 0.175 * 2),
                          top: areaHeight * 0.025,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.225,
                            child: buttonControl.widgets[startIndex + 8],
                          )
                      ),

                      // TT +/-
                      Positioned(
                          left: areaWidth * 0.85,
                          top: areaHeight * 0.025,
                          child: Container(
                            width: areaWidth * 0.13,
                            height: areaHeight * 0.95,
                            child: buttonControl.widgets[startIndex + 10],
                          )
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget buildTurntable(BuildContext context, int player) {
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              var areaWidth = constraints.maxWidth;
              var areaHeight = constraints.maxHeight;
              return Stack(
                children: [

                  // tt +/-
                  Positioned(
                    left: areaWidth * 0.05,
                    top: areaHeight * 0.05,
                    child: Container(
                      width: areaWidth * 0.9,
                      height: areaHeight * 0.9,
                      child: buttonControl.widgets[
                      (player == 1) ? 10 : 21
                      ],
                    )
                  ),

                  // player text
                  Positioned(
                    left: areaWidth * 0.45,
                    top: areaHeight * 0.45,
                    child: Container(
                      width: areaWidth * 0.2,
                      height: areaHeight * 0.2,
                      child: Text("P" + player.toString() + " TT +/-"),
                    )
                  ),

                ],
              );
            }
          ),
        ),
      )
    );
  }
}
