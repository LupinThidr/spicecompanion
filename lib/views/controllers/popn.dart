part of views;

class POPNButton extends ButtonControlButton {

  POPNButton(ValueListenable listenable, String name)
      : super(listenable, name);

  @override
  POPNButtonState createState() => POPNButtonState(this, listenable);
}

class POPNButtonState extends ButtonControlButtonState {
  POPNButtonState(listenable, button) : super(listenable, button);

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: () {
          var viewNo = controllerViewNo.value % 2;
          if (viewNo == 0)
            return BoxShape.circle;
          return BoxShape.rectangle;
        } (),
        color: () {
          if (button.name.endsWith("1")
              || (button.name.endsWith("9"))) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFFE0E0E0);
          }
          if (button.name.endsWith("2")
              || (button.name.endsWith("8"))) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFFF0F050);
          }
          if (button.name.endsWith("3")
              || (button.name.endsWith("7"))) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFF50B050);
          }
          if (button.name.endsWith("4")
              || (button.name.endsWith("6"))) {
            return button.isDown()
                ? Color(0xFF501010)
                : Color(0xFF5050E0);
          }
          return button.isDown()
              ? Color(0xFF501010)
              : Color(0xFFD05050);
        } (),
      )
    );
  }
}

class POPNControllerView extends StatefulWidget {

  @override
  POPNControllerViewState createState() => POPNControllerViewState();
}

class POPNControllerViewState extends State<POPNControllerView> {
  ButtonControl buttonControl;

  @override
  void initState() {
    super.initState();
    buttonControl = new ButtonControl();
    buttonControl.widgets = [
      POPNButton(buttonControl.notifier, "Button 1"),
      POPNButton(buttonControl.notifier, "Button 2"),
      POPNButton(buttonControl.notifier, "Button 3"),
      POPNButton(buttonControl.notifier, "Button 4"),
      POPNButton(buttonControl.notifier, "Button 5"),
      POPNButton(buttonControl.notifier, "Button 6"),
      POPNButton(buttonControl.notifier, "Button 7"),
      POPNButton(buttonControl.notifier, "Button 8"),
      POPNButton(buttonControl.notifier, "Button 9"),
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

                      // button 1
                      Positioned(
                        left: areaWidth * (0.075 + 0.175 * 0),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[0],
                        )
                      ),

                      // button 3
                      Positioned(
                        left: areaWidth * (0.075 + 0.175 * 1),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[2],
                        )
                      ),

                      // button 5
                      Positioned(
                        left: areaWidth * (0.075 + 0.175 * 2),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[4],
                        )
                      ),

                      // button 7
                      Positioned(
                        left: areaWidth * (0.075 + 0.175 * 3),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[6],
                        )
                      ),

                      // button 9
                      Positioned(
                        left: areaWidth * (0.075 + 0.175 * 4),
                        top: areaHeight * 0.525,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.2125,
                          child: buttonControl.widgets[8],
                        )
                      ),

                      // button 2
                      Positioned(
                        left: areaWidth * (0.1625 + 0.175 * 0),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
                          child: buttonControl.widgets[1],
                        )
                      ),

                      // button 4
                      Positioned(
                        left: areaWidth * (0.1625 + 0.175 * 1),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
                          child: buttonControl.widgets[3],
                        )
                      ),

                      // button 6
                      Positioned(
                        left: areaWidth * (0.1625 + 0.175 * 2),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
                          child: buttonControl.widgets[5],
                        )
                      ),

                      // button 8
                      Positioned(
                        left: areaWidth * (0.1625 + 0.175 * 3),
                        top: areaHeight * 0.025,
                        child: Container(
                          width: areaWidth * 0.15,
                          height: areaWidth * 0.225,
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
