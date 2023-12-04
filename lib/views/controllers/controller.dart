part of views;

final controllerViewNo = ValueNotifier<int>(0);

class ControllerView extends StatefulWidget {

  @override
  _ControllerViewState createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {

  @override
  void initState() {
    super.initState();

    // refresh state on connection change
    ConnectionPool.inst.changes.stream.listen((pool) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controllerViewNo,
      builder: (context, value, child) {

        // get sub view based on connected game
        Widget subView = Text(":)");
        switch (gameModel) {
          case "J44":
          case "K44":
          case "L44": {
            subView = JBControllerView();
            break;
          }
          case "LDJ": {
            subView = IIDXControllerView();
            break;
          }
          case "K39":
          case "L39":
          case "M39": {
            subView = POPNControllerView();
            break;
          }
          case "PAN": {
            subView = NostControllerView();
            break;
          }
          case "KFC": {
            subView = SDVXControllerView();
            break;
          }
          case "MDX": {
            subView = DDRControllerView();
            break;
          }
          case "R66": {
            subView = BBCControllerView();
            break;
          }
          case "JMP": {
            subView = HPMControllerView();
            break;
          }
          case "JGT": {
            subView = RF3DControllerView();
            break;
          }
          case "MMD": {
            subView = FTTControllerView();
            break;
          }
          case "KLP": {
            subView = LPControllerView();
            break;
          }
          case "REC": {
            subView = DRSControllerView();
            break;
          }
          case "KCK":
          case "NCK": {
            subView = WEControllerView();
            break;
          }
          default:
            if (gameModel == null || gameModel == "")
              subView = Text(
                  "Please connect to a server first."
              );
            else
              subView = Text(
                  "This game does not yet have a controller view :("
              );
            break;
        }

        // return container of sub view
        return Container(
          child: Center(
              child: subView
          ),
        );
      },
    );
  }
}
