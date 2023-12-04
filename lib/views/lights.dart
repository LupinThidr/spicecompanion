part of views;

class LightsView extends StatefulWidget {
  _LightsViewState createState() => _LightsViewState();
}

class _LightsViewState extends State<LightsView> {

  List<LightState> _lightStates = List();
  bool _lightStatesLock = false;
  Timer refreshTimer;
  int updateCount = 0;
  bool locked = false;
  List<String> ignoreLightNames = List();

  @override
  void initState() {
    super.initState();
    ignoreLightNames = List();
    if (!locked)
      freeList();
    update();
  }

  @override
  void dispose() {
    if (refreshTimer != null)
      refreshTimer.cancel();
    if (!locked)
      freeList();
    super.dispose();
  }

  Future<void> writeSingle(LightState state) async {
    return ConnectionPool.inst.get().then((con) {
      return lightsWrite(con, [state]).whenComplete(() {
        locked = true;
        state.active = true;
        con.free();
      });
    }, onError: (e) {});
  }

  Future<void> writeList() async {
    return ConnectionPool.inst.get().then((con) {
      if (_lightStates == null || _lightStates.length == 0)
        return null;
      return lightsWrite(con, _lightStates).whenComplete(() => con.free());
    }, onError: (e) {});
  }

  Future<void> freeList() async {
    return ConnectionPool.inst.get().then((con) {
      lightsWriteReset(con, []).whenComplete(() => con.free());
    }, onError: (e) {});
  }

  void update() {

    // update timer
    if (refreshTimer == null || refreshTimer.tick >= 64) {
      if (refreshTimer != null)
        refreshTimer.cancel();
      refreshTimer = Timer.periodic(
        Duration(milliseconds: max(128, lastPing.inMilliseconds)),
          (timer) => update()
      );
    }

    // update lights
    if (updateCount < 2) {
      updateCount++;
      ConnectionPool.inst.get().then((con) {
        lightsRead(con).then((stateList) {

          // check lock first
          if (_lightStatesLock)
            return;

          // apply new list
          _lightStatesLock = true;
          List<LightState> newList = List();
          for (var newState in stateList) {
            if (newState.active)
              locked = true;
            if (!ignoreLightNames.contains(newState.name))
              newList.add(newState);
            else
              newList.addAll(_lightStates.where(
                  (oldState) => oldState.name == newState.name
              ));
          }
          _lightStates = newList;
          _lightStatesLock = false;

          try {
            setState(() {});
          } on Error {}

        }).whenComplete(() => con.free());
      }, onError: (e) {

        // clear list on disconnect
        _lightStates = List();
      }).whenComplete(() => updateCount--);
    }
  }

  @override
  Widget build(BuildContext context) {

    // empty view
    if (_lightStates.length == 0)
      return Container(
        child: Center(
            child: Text('No lights available :(')
        ),
      );

    // list view
    return Scaffold(
      body: ListView(
        children: _lightStates.map((light) {

          // title color
          var titleColor = light.active ? Colors.orange : null;

          return ListTile(
            title: Text(light.name, style: TextStyle(color: titleColor)),
            subtitle: Slider(
              value: light.state,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              onChanged: (value) {
                light.state = value;
                writeSingle(light);
                setState(() {});
              },
              onChangeStart: (value) {
                ignoreLightNames.add(light.name);
              },
              onChangeEnd: (value) {
                ignoreLightNames.remove(light.name);
                light.state = value;
                writeSingle(light);
                setState(() {});
              },
            ),
            onTap: () async {
              if (light.state >= 0.5)
                light.state = 0;
              else
                light.state = 1;
              await writeSingle(light);
              setState(() {});
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(locked ? Icons.lock : Icons.lock_open),
        onPressed: () {
          if (locked) {
            locked = false;
            freeList();
          } else {
            locked = true;
            writeList();
          }
          setState(() {});
        },
        backgroundColor: locked ? Colors.red : null,
      ),
    );
  }
}
