part of views;

class Settings {
  static const preferencesKey = "settings";

  static bool settingsLoaded = false;

  static bool _darkMode;
  static get darkMode {
    return _darkMode;
  }
  static set darkMode(bool value) {
    if (_darkMode == value)
      return;
    switch (value) {
      case false:
        currentTheme = SpiceTheme.Light;
        break;
      case true:
        currentTheme = SpiceTheme.Dark;
        break;
    }
    _darkMode = value;
    save();
  }

  static void save() {
    if (!settingsLoaded)
      return;

    // build map
    var map = {};
    map["darkMode"] = darkMode;
    var json = jsonEncode(map);

    // save
    Storage storage = window.localStorage;
    storage[preferencesKey] = json;
  }

  static void load() async {
    defaults();
    Storage storage = window.localStorage;
    if (storage.containsKey(preferencesKey)) {
      try {
        var json = storage[preferencesKey];
        var map = jsonDecode(json);
        darkMode = map["darkMode"] ?? darkMode;
      } on Error {
        storage.remove(preferencesKey);
      }
    }
    settingsLoaded = true;
  }

  static void defaults() {
    darkMode = true;
  }
}

class SettingsView extends StatefulWidget {

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text("Dark Mode"),
            value: Settings.darkMode,
            onChanged: (value) {
              Settings.darkMode = value;
              setState(() {});
            },
          ),
          ListTile(
            title: Text("Restart Game"),
            onTap: () {
              ConnectionPool.inst.get().then((con) {
                controlRestart(con).catchError((e) {
                }).whenComplete(() => con.free());
              }, onError: (e) {});
            },
          ),
          ListTile(
            title: Text("Kill Game"),
            onTap: () {
              ConnectionPool.inst.get().then((con) {
                controlExit(con, 0).catchError((e) {
                }).whenComplete(() => con.free());
              }, onError: (e) {});
            },
          ),
          ListTile(
            title: Text("Licenses"),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
          ListTile(
            title: Text("About"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => AboutView()
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutView extends StatefulWidget {

  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {

  String content = "";

  @override
  void initState() {
    super.initState();

    // load file
    rootBundle.loadString("assets/about.txt").then((file) {
      content = file;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About")
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(content, style: TextStyle(fontSize: 23),),
        ),
      ),
    );
  }
}
