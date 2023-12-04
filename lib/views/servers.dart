part of views;

const cStoredServers = 'server_list'; // preferences key
List<ServerInfo> serverList = List<ServerInfo>();

class ServerInfo {
  String name = "Server";
  String address = "127.0.0.1";
  String port = "1337";
  String pass = "";

  ServerInfo({
    @required this.name,
    @required this.address,
    @required this.port,
    @required this.pass
  });

  ServerInfo.fromJson(String json) {
    Map obj = jsonDecode(json);
    name = obj["name"] ?? name;
    address = obj["address"] ?? address;
    port = obj["port"] ?? port;
    pass = obj["pass"] ?? pass;
  }

  String toJson() {
    return jsonEncode({
      "name": name,
      "address": address,
      "port": port,
      "pass": pass,
    });
  }
}

class ServerView extends StatefulWidget {
  _ServerViewState createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  Timer serverViewTimer;

  @override
  void initState() {
    super.initState();
    if (serverViewTimer != null)
      serverViewTimer.cancel();
    serverViewTimer = Timer.periodic(
        Duration(milliseconds: 500),
        serverViewTick
    );

    // reload server list
    preferencesGetStringList(cStoredServers).then((storedList) {
      if (storedList != null) {
        List<ServerInfo> newList = List<ServerInfo>();
        for (var json in storedList) {
          try {
            var server = ServerInfo.fromJson(json);
            newList.add(server);
          } catch (Exception) {
            debugPrint("Couldn't parse ServerInfo: $json");
          }
        }
        serverList = newList;
        if (mounted)
          setState(() {});
      }
    });
  }

  @override
  void dispose() {
    if (serverViewTimer != null)
      serverViewTimer.cancel();
    serverViewTimer = null;
    super.dispose();
  }

  void serverViewTick(Timer _) {

    // auto refresh state for connected/disconnected state
    try {
      setState(() {});
    } catch (Exception) {}

  }

  Future<void> saveServerList() {
    return preferencesSetStringList(cStoredServers,
        serverList.map((s) => s.toJson()).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    var hasConnection = ConnectionPool.inst.hasConnection();
    return Scaffold(
      // Build server list from `serverList`
      body: ListView(
        children: serverList.map((ServerInfo s) {
          var isCon = ConnectionPool.inst.isActive(s.address, s.port, s.pass);
          var isConStr = isCon ? " (Active)" : "";
          if (isCon && !hasConnection)
            isConStr = " (Disconnected)";
          return ListTile(
            title: Text(
                "${s.name}$isConStr",
              style: !isCon ? null : TextStyle(
                color: hasConnection ? Colors.lightGreen : Colors.orange
              ),
            ),
            subtitle: Text('${s.address}:${s.port}'),
            onTap: () {

              // check for connect/disconnect
              if (!isCon) _tryConnect(s);
              else {

                // show disconnect info
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Disconnected."),
                  backgroundColor: Colors.orange,
                  duration: Duration(milliseconds: 500),
                ));

                ConnectionPool.inst.disconnect();
                setState(() {});
              }
            },
            onLongPress: () => _showOptions(s),
          );
        }).toList()
      ),

      // 'Add Server' Button
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return ServerEditView(
                  onSave: (ServerInfo server) {
                    setState(() => serverList.add(server));
                    saveServerList();
                  },
                );
              }
            ),
          );
        },
      ),
    );
  }

  bool connecting = false;

  void _tryConnect(ServerInfo server) {

    // abort if already trying to connect
    if (connecting)
      return;

    // change server details
    ConnectionPool.inst.changeServer(
      server.address,
      int.parse(server.port),
      server.pass
    );

    // attempt to get a connection
    connecting = true;
    Connection connection;
    ConnectionPool.inst.get().then((con) {

      // accept connection
      connection = con;

      // show info
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Connected to ${server.address}:${server.port}"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));

      // query avs info to test
      return infoAVS(con);
    },
    onError: (err) {
      ConnectionPool.inst.disconnect();

      // show error
      var text = "";
      if (err is APIError)
        text = "Failed to connect: Wrong password?";
      else
        text = "Failed to connect to ${server.address}:${server.port}";
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));

    }).then((avs) {
      if (connection != null)
        connection.free();
    }, onError: (err) {
      ConnectionPool.inst.disconnect();
    }).whenComplete(() {
      connecting = false;

      // update state since the active server changed
      if (mounted)
        setState(() {});

    });
  }

  void _showOptions(ServerInfo server) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.edit),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text('Edit \'${server.name}\''),
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => ServerEditView(
                    baseDetails: server,
                    onSave: (ServerInfo newServer) {
                      setState(() {
                        server.name = newServer.name;
                        server.address = newServer.address;
                        server.port = newServer.port;
                        server.pass = newServer.pass;
                      });
                      saveServerList();
                    },
                  ),
                ),
              );
            }
          ),
          SimpleDialogOption(
            child: Row(
              children: <Widget>[
                Icon(Icons.delete),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text('Remove'),
                ),
              ],
            ),
            onPressed: () {
              setState(() => serverList.remove(server));
              saveServerList();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class ServerEditView extends StatefulWidget {
  ServerEditView({@required this.onSave, this.baseDetails});

  final void Function(ServerInfo) onSave;
  // If none provided, the UI will say 'Add' not 'Edit'/'Save'
  final ServerInfo baseDetails;

  _ServerEditViewState createState() => _ServerEditViewState();
}

class _ServerEditViewState extends State<ServerEditView> {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  AutovalidateMode _autoValidateFields = AutovalidateMode.disabled;
  ServerInfo _data;

  @override
  void initState() {
    super.initState();
    if (widget.baseDetails == null) {
      _data = ServerInfo(name: '', address: '', port: '', pass: '');
    } else {
      _data = ServerInfo(
        name: widget.baseDetails.name,
        address: widget.baseDetails.address,
        port: widget.baseDetails.port,
        pass: widget.baseDetails.pass
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baseDetails == null ? 'Add Server' : 'Edit Server'),
      ),
      body: Form(
        key: _formState,
        child: NoOverglow(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.account_circle),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Main Computer',
                  ),
                  onSaved: (String s) => _data.name = s,
                  validator: validateBasic,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.cloud),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.address,
                  decoration: InputDecoration(
                    labelText: 'Host Address',
                    hintText: '127.0.0.1',
                  ),
                  keyboardType: TextInputType.url,
                  onSaved: (String s) => _data.address = s,
                  validator: validateBasic,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.storage),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.port,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    hintText: '1337',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (String s) => _data.port = s,
                  validator: (String s) {
                    var basic = validateBasic(s);
                    if (basic != null) return basic;
                    if (int.tryParse(s) == null)
                      return 'Must be a valid integer!';
                    return null;
                  },
                  autovalidateMode: _autoValidateFields,
                ),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: TextFormField(
                  autocorrect: false,
                  initialValue: _data.pass,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'changeme (optional)',
                  ),
                  obscureText: true,
                  onSaved: (String s) => _data.pass = s,
                  validator: null,
                  autovalidateMode: _autoValidateFields,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text(widget.baseDetails == null ? 'Add' : 'Save'),
            onPressed: () {
              if(_formState.currentState.validate()) {
                _formState.currentState.save();
                widget.onSave(_data);
                Navigator.of(context).pop();
              } else {
                setState(() {
                  // upon trying to add/resave invalid data,
                  // it'll be validated every time the fields change
                  // until you save it.
                  _autoValidateFields = AutovalidateMode.always;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String validateBasic(String s) {
    if (s.length == 0) return "Can't be empty!";
    return null;
  }
}

// Captures ListView overglows (fx when you scroll too far in either direction)
class NoOverglow extends StatelessWidget {
  final Widget child;

  NoOverglow({@required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      child: child,
      onNotification: (notification) {
        notification.disallowGlow();
        return true;
      },
    );
  }
}
