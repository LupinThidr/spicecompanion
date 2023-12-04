part of views;

class HPMButton extends ButtonControlButton {

  HPMButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  HPMButtonState createState() => HPMButtonState(this, listenable);
}

class HPMButtonState extends ButtonControlButtonState {
  HPMButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: () {
          if (button.name.endsWith("1")) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFFD05050);
          }
          if (button.name.endsWith("3")) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFFF0F050);
          }
          if (button.name.endsWith("4")) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFF50B050);
          }
          if (button.name.endsWith("2")) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFF5050E0);
          }
          return button.isDown()
              ? Color(0xFF501010)
              : Color(0xFFF0F0F0);
        } (),
      )
    );
  }
}

class HPMControllerView extends StatefulWidget {

  @override
  HPMControllerViewState createState() => HPMControllerViewState();
}

class HPMControllerViewState extends State<HPMControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      HPMButton(buttonControl.notifier, "P1 Start"),
      HPMButton(buttonControl.notifier, "P1 1"),
      HPMButton(buttonControl.notifier, "P1 2"),
      HPMButton(buttonControl.notifier, "P1 3"),
      HPMButton(buttonControl.notifier, "P1 4"),
      HPMButton(buttonControl.notifier, "P2 Start"),
      HPMButton(buttonControl.notifier, "P2 1"),
      HPMButton(buttonControl.notifier, "P2 2"),
      HPMButton(buttonControl.notifier, "P2 3"),
      HPMButton(buttonControl.notifier, "P2 4"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var viewCount = 2;
    var viewNo = controllerViewNo.value % viewCount;
    if (viewNo == 0) return buildSingle(context, 1);
    if (viewNo == 1) return buildSingle(context, 2);
    return null;
  }

  Widget buildSingle(BuildContext context, int player) {
    int startIndex = player == 2 ? 5 : 0;
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

                      // player text
                      Positioned(
                        left: areaWidth * 0.02,
                        top: areaHeight * 0.02,
                        child: Container(
                          width: areaWidth * 0.05,
                          height: areaWidth * 0.05,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text("P" + player.toString()),
                          ),
                        )
                      ),

                      // start
                      Positioned(
                        left: areaWidth * (0.51 - 0.15 * 0.5),
                        top: areaHeight * 0.05,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.15,
                          child: buttonControl.widgets[startIndex + 0],
                        )
                      ),

                      // button 1
                      Positioned(
                        left: areaWidth * (0.075 + 0.222 * 0),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[startIndex + 1],
                        )
                      ),

                      // button 2
                      Positioned(
                        left: areaWidth * (0.075 + 0.222 * 1),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[startIndex + 2],
                        )
                      ),

                      // button 3
                      Positioned(
                        left: areaWidth * (0.075 + 0.222 * 2),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[startIndex + 3],
                        )
                      ),

                      // button 4
                      Positioned(
                        left: areaWidth * (0.075 + 0.222 * 3),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.2,
                          height: areaWidth * 0.2,
                          child: buttonControl.widgets[startIndex + 4],
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
