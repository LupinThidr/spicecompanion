part of views;

class SDVXButton extends ButtonControlButton {

  SDVXButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  SDVXButtonState createState() => SDVXButtonState(this, listenable);
}

class SDVXButtonState extends ButtonControlButtonState {
  SDVXButtonState(listenable, button) : super(listenable, button);

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

class SDVXControllerView extends StatefulWidget {

  @override
  SDVXControllerViewState createState() => SDVXControllerViewState();
}

class SDVXControllerViewState extends State<SDVXControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      SDVXButton(buttonControl.notifier, "BT-A"),
      SDVXButton(buttonControl.notifier, "BT-B"),
      SDVXButton(buttonControl.notifier, "BT-C"),
      SDVXButton(buttonControl.notifier, "BT-D"),
      SDVXButton(buttonControl.notifier, "FX-L"),
      SDVXButton(buttonControl.notifier, "FX-R"),
      SDVXButton(buttonControl.notifier, "Start"),
      SDVXButton(buttonControl.notifier, "VOL-L Left"),
      SDVXButton(buttonControl.notifier, "VOL-L Right"),
      SDVXButton(buttonControl.notifier, "VOL-R Left"),
      SDVXButton(buttonControl.notifier, "VOL-R Right"),
    ];
  }

  @override
  Widget build(BuildContext context) {
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

                      // bt-a
                      Positioned(
                          left: areaWidth * (0.125 + 0.2 * 0),
                          top: areaHeight * 0.35,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.15,
                            child: buttonControl.widgets[0],
                          )
                      ),

                      // bt-b
                      Positioned(
                          left: areaWidth * (0.125 + 0.2 * 1),
                          top: areaHeight * 0.35,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.15,
                            child: buttonControl.widgets[1],
                          )
                      ),

                      // bt-c
                      Positioned(
                          left: areaWidth * (0.125 + 0.2 * 2),
                          top: areaHeight * 0.35,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.15,
                            child: buttonControl.widgets[2],
                          )
                      ),

                      // bt-d
                      Positioned(
                          left: areaWidth * (0.125 + 0.2 * 3),
                          top: areaHeight * 0.35,
                          child: Container(
                            width: areaWidth * 0.15,
                            height: areaWidth * 0.15,
                            child: buttonControl.widgets[3],
                          )
                      ),

                      // fx-l
                      Positioned(
                          left: areaWidth * 0.2,
                          top: areaHeight * 0.75,
                          child: Container(
                            width: areaWidth * 0.2125,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[4],
                          )
                      ),

                      // fx-r
                      Positioned(
                          left: areaWidth * 0.575,
                          top: areaHeight * 0.75,
                          child: Container(
                            width: areaWidth * 0.2125,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[5],
                          )
                      ),

                      // start
                      Positioned(
                          left: areaWidth * (0.5 - 0.05),
                          top: areaHeight * 0.05,
                          child: Container(
                            width: areaWidth * 0.1,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[6],
                          )
                      ),

                      // vol-l left
                      Positioned(
                          left: areaWidth * (0.075 - 0.05),
                          top: areaHeight * 0.05,
                          child: Container(
                            width: areaWidth * 0.125,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[7],
                          )
                      ),

                      // vol-l right
                      Positioned(
                          left: areaWidth * (0.225 - 0.05),
                          top: areaHeight * 0.05,
                          child: Container(
                            width: areaWidth * 0.125,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[8],
                          )
                      ),

                      // vol-r left
                      Positioned(
                          left: areaWidth * (0.75 - 0.05),
                          top: areaHeight * 0.05,
                          child: Container(
                            width: areaWidth * 0.125,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[9],
                          )
                      ),

                      // vol-r right
                      Positioned(
                          left: areaWidth * (0.9 - 0.05),
                          top: areaHeight * 0.05,
                          child: Container(
                            width: areaWidth * 0.125,
                            height: areaWidth * 0.1,
                            child: buttonControl.widgets[10],
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
}
