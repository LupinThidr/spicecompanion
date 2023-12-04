part of views;

class RF3DButton extends ButtonControlButton {

  RF3DButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  RF3DButtonState createState() => RF3DButtonState(this, listenable);
}

class RF3DButtonState extends ButtonControlButtonState {
  RF3DButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var areaWidth = constraints.maxWidth;
        var areaHeight = constraints.maxHeight;
        var areaMin = min(areaWidth, areaHeight);
        return Container(
          decoration: BoxDecoration(
            color: button.isDown()
                ? Color(0xFF501010)
                : Color(0xFF505050),
          ),
          child: Icon(() {
            if (button.name.endsWith("View"))
              return Icons.refresh;
            if (button.name.endsWith("2D/3D"))
              return Icons.search;
            if (button.name.endsWith("Accelerate"))
              return Icons.arrow_upward;
            if (button.name.endsWith("Brake"))
              return Icons.arrow_downward;
            if (button.name.endsWith("Wheel Left"))
              return Icons.keyboard_arrow_left;
            if (button.name.endsWith("Wheel Right"))
              return Icons.keyboard_arrow_right;
            if (button.name.endsWith("Auto Lever Up"))
              return Icons.arrow_drop_up;
            if (button.name.endsWith("Auto Lever Down"))
              return Icons.arrow_drop_down;
            return null;
          } (), size: areaMin),
        );
      },
    );
  }
}

class RF3DControllerView extends StatefulWidget {

  @override
  RF3DControllerViewState createState() => RF3DControllerViewState();
}

class RF3DControllerViewState extends State<RF3DControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      RF3DButton(buttonControl.notifier, "View"),
      RF3DButton(buttonControl.notifier, "2D/3D"),
      RF3DButton(buttonControl.notifier, "Wheel Left"),
      RF3DButton(buttonControl.notifier, "Wheel Right"),
      RF3DButton(buttonControl.notifier, "Accelerate"),
      RF3DButton(buttonControl.notifier, "Brake"),
      RF3DButton(buttonControl.notifier, "Auto Lever Down"),
      RF3DButton(buttonControl.notifier, "Auto Lever Up"),
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

                      // view
                      Positioned(
                        left: areaWidth * 0.42,
                        top: areaHeight * 0.05,
                        child: Container(
                          width: areaWidth * 0.075,
                          height: areaWidth * 0.075,
                          child: buttonControl.widgets[0],
                        )
                      ),

                      // 2D/3D
                      Positioned(
                          left: areaWidth * 0.51,
                          top: areaHeight * 0.05,
                          child: Container(
                            width: areaWidth * 0.075,
                            height: areaWidth * 0.075,
                            child: buttonControl.widgets[1],
                          )
                      ),

                      // wheel left
                      Positioned(
                        left: areaWidth * 0.05,
                        top: areaHeight * 0.1,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaHeight * 0.8,
                          child: buttonControl.widgets[2],
                        )
                      ),

                      // wheel right
                      Positioned(
                        left: areaWidth * 0.22,
                        top: areaHeight * 0.1,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaHeight * 0.8,
                          child: buttonControl.widgets[3],
                        )
                      ),

                      // accelerate
                      Positioned(
                        left: areaWidth * 0.80,
                        top: areaHeight * 0.1,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaHeight * 0.8,
                          child: buttonControl.widgets[4],
                        )
                      ),

                      // brake
                      Positioned(
                        left: areaWidth * 0.63,
                        top: areaHeight * 0.1,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaHeight * 0.8,
                          child: buttonControl.widgets[5],
                        )
                      ),

                      // lever down
                      Positioned(
                        left: areaWidth * 0.45,
                        top: areaHeight * 0.61,
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaHeight * 0.29,
                          child: buttonControl.widgets[6],
                        )
                      ),

                      // lever up
                      Positioned(
                        left: areaWidth * 0.45,
                        top: areaHeight * 0.29,
                        child: Container(
                          width: areaWidth * 0.1,
                          height: areaHeight * 0.3,
                          child: buttonControl.widgets[7],
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
