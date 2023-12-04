part of views;

class ControllerView extends StatefulWidget {

  @override
  _ControllerViewState createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Center(
         child: Text('Controller View')
       ),
    );
  }
}
