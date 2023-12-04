part of views;

class BBCButton extends ButtonControlButton {

  BBCButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  BBCButtonState createState() => BBCButtonState(this, listenable);
}

class BBCButtonState extends ButtonControlButtonState {
  BBCButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var areaWidth = constraints.maxWidth;
        var areaHeight = constraints.maxHeight;
        var areaMin = min(areaWidth, areaHeight);
        return Container(
          decoration: BoxDecoration(
            color: () {
              if (button.name.endsWith("R")) {
                return button.isDown()
                    ? Color(0xFF501010)
                    : Color(0xFFF05050);
              }
              if (button.name.endsWith("G")) {
                return button.isDown()
                    ? Color(0xFF501010)
                    : Color(0xFF50F050);
              }
              if (button.name.endsWith("B")) {
                return button.isDown()
                    ? Color(0xFF501010)
                    : Color(0xFF5050F0);
              }
              if (button.name.endsWith("Slowdown")) {
                return button.isDown()
                    ? Color(0xFF300909)
                    : Color(0xFF303030);
              }
              return button.isDown()
                  ? Color(0xFF501010)
                  : Color(0xFF505050);
            } (),
          ),
          child: Icon(() {
            if (button.name.endsWith("+"))
              return Icons.keyboard_arrow_right;
            if (button.name.endsWith("-"))
              return Icons.keyboard_arrow_left;
            return null;
          } (), size: areaMin),
        );
      },
    );
  }
}

class BBCControllerView extends StatefulWidget {

  @override
  BBCControllerViewState createState() => BBCControllerViewState();
}

class BBCControllerViewState extends State<BBCControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      BBCButton(buttonControl.notifier, "P1 R"),
      BBCButton(buttonControl.notifier, "P1 G"),
      BBCButton(buttonControl.notifier, "P1 B"),
      BBCButton(buttonControl.notifier, "P1 Disk-"),
      BBCButton(buttonControl.notifier, "P1 Disk+"),
      BBCButton(buttonControl.notifier, "P1 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P1 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P2 R"),
      BBCButton(buttonControl.notifier, "P2 G"),
      BBCButton(buttonControl.notifier, "P2 B"),
      BBCButton(buttonControl.notifier, "P2 Disk-"),
      BBCButton(buttonControl.notifier, "P2 Disk+"),
      BBCButton(buttonControl.notifier, "P2 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P2 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P3 R"),
      BBCButton(buttonControl.notifier, "P3 G"),
      BBCButton(buttonControl.notifier, "P3 B"),
      BBCButton(buttonControl.notifier, "P3 Disk-"),
      BBCButton(buttonControl.notifier, "P3 Disk+"),
      BBCButton(buttonControl.notifier, "P3 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P3 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P4 R"),
      BBCButton(buttonControl.notifier, "P4 G"),
      BBCButton(buttonControl.notifier, "P4 B"),
      BBCButton(buttonControl.notifier, "P4 Disk-"),
      BBCButton(buttonControl.notifier, "P4 Disk+"),
      BBCButton(buttonControl.notifier, "P4 Disk -/+ Slowdown"),
      BBCButton(buttonControl.notifier, "P4 Disk -/+ Slowdown"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var viewCount = 4;
    var viewNo = controllerViewNo.value % viewCount;
    if (viewNo == 0) return buildSingle(context, 1);
    if (viewNo == 1) return buildSingle(context, 2);
    if (viewNo == 2) return buildSingle(context, 3);
    if (viewNo == 3) return buildSingle(context, 4);
    return null;
  }

  Widget buildSingle(BuildContext context, int player) {
    int startIndex = (player - 1) * 7;
    return buttonControl.wrapListener(
      Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: AspectRatio(
            aspectRatio: 19 / 9,
            child: Container(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var areaWidth = constraints.maxWidth;
                  var areaHeight = constraints.maxHeight;
                  return Stack(
                    children: [

                      // red
                      Positioned(
                        left: areaWidth * (0.25 / 4 + (0.25 + 0.25 / 4) * 0),
                        top: areaHeight * 0.45,
                        child: Container(
                          width: areaWidth * 0.25,
                          height: areaHeight * 0.5,
                          child: buttonControl.widgets[startIndex + 0],
                        )
                      ),

                      // green
                      Positioned(
                        left: areaWidth * (0.25 / 4 + (0.25 + 0.25 / 4) * 1),
                        top: areaHeight * 0.45,
                        child: Container(
                          width: areaWidth * 0.25,
                          height: areaHeight * 0.5,
                          child: buttonControl.widgets[startIndex + 1],
                        )
                      ),

                      // blue
                      Positioned(
                        left: areaWidth * (0.25 / 4 + (0.25 + 0.25 / 4) * 2),
                        top: areaHeight * 0.45,
                        child: Container(
                          width: areaWidth * 0.25,
                          height: areaHeight * 0.5,
                          child: buttonControl.widgets[startIndex + 2],
                        )
                      ),

                      // disk minus
                      Positioned(
                        left: areaWidth * (0.25 / 4),
                        top: areaHeight * 0.05,
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaHeight * 0.3,
                          child: buttonControl.widgets[startIndex + 3],
                        )
                      ),

                      // disk minus slow
                      Positioned(
                        left: areaWidth * (0.25 / 4 + 0.25 - 0.05),
                        top: areaHeight * 0.05,
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaHeight * 0.3,
                          child: buttonControl.widgets[startIndex + 5],
                        )
                      ),

                      // disk plus
                      Positioned(
                        left: areaWidth * (0.25 / 4
                            + (0.25 + 0.25 / 4) * 2 - 0.05),
                        top: areaHeight * 0.05,
                        child: Container(
                          width: areaWidth * 0.3,
                          height: areaHeight * 0.3,
                          child: buttonControl.widgets[startIndex + 4],
                        )
                      ),

                      // disk plus slow
                      Positioned(
                        left: areaWidth * (0.25 / 4
                            + (0.25 + 0.25 / 4) * 2 - 0.05),
                        top: areaHeight * 0.05,
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaHeight * 0.3,
                          child: buttonControl.widgets[startIndex + 6],
                        )
                      ),

                      // player text
                      Positioned(
                        left: areaWidth * 0.45,
                        top: areaWidth * 0.05,
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaWidth * 0.1,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text("P" + player.toString()),
                          ),
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
