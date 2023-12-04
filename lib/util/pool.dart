part of util;

class _ConnectionPoolEntry {
  Connection con;
  DateTime lastRefresh;

  _ConnectionPoolEntry(this.con) {
    lastRefresh = DateTime.now();
  }
}

class ConnectionPool {
  static const Duration SESSION_REFRESH = Duration(seconds: 60);

  // app wide pool
  static ConnectionPool inst = ConnectionPool();

  // the pool to limit the amount of concurrent connections
  final _pool = new Pool(16, timeout: Duration(seconds: 3));

  // cache last connections
  final List<_ConnectionPoolEntry> _entries = [];
  StreamController<ConnectionPool> changes;

  // state
  String _host = "";
  int _port = 0;
  String _pass = "";

  ConnectionPool() {
    this.changes = StreamController<ConnectionPool>.broadcast();
  }

  void dispose() {
    this.changes.close();
    this.changes = null;
    this.clear();
  }

  bool isActive(String host, String port, String pass) {
    return this._host == host
        && this._port.toString() == port
        && this._pass == pass;
  }

  bool hasConnection() {
    for (var entry in _entries)
      if (entry.con.isValid()) return true;
    return false;
  }

  bool hasPassword() {
    return _pass != null && _pass.length > 0;
  }

  void disconnect() {
    _host = "";
    _port = 0;
    _pass = "";
    this.clear();
    this.changes.add(this);
  }

  void changeServer(String host, int port, String pass) {

    // check if unnecessary
    if (_host == host && _port == port && _pass == pass)
      return;

    // apply settings
    this._host = host;
    this._port = port;
    this._pass = pass;
    this.clear();

    // notify
    if (this.changes != null)
      this.changes.add(this);
  }

  void clear() {

    // kill all connections
    for (var entry in _entries) entry.con.dispose();
    _entries.clear();
  }

  Future<Connection> get() {

    // check host
    if (_host.isEmpty) return Future<Connection>(() {
      throw new StateError("Disconnected.");
    });

    // request connection
    return _pool.request().then((resource) async {

      // find free connection
      for (int i = 0; i < _entries.length;) {
        var entry = _entries[i++];
        if (entry.con.isFree()) {
          if (entry.con.isValid()) {

            // pass resource
            entry.con.resource = resource;

            // refresh session
            var diff = DateTime.now().difference(entry.lastRefresh);
            if (diff > SESSION_REFRESH) {
              await controlRefreshSession(entry.con);
              entry.lastRefresh = DateTime.now();
            }

            // return connection
            return entry.con;

          } else {

            // dispose invalid connections
            entry.con.dispose();
            _entries.removeAt(i - 1);
          }
        }
      }

      // create connection with pool resource
      var con = Connection(_host, _port, _pass, resource: resource);
      await con.onConnect();
      if (con.isDisposed())
        throw new APIError("disposed");

      // remember it so we can close/reuse it later
      _entries.add(_ConnectionPoolEntry(con));

      // return connection
      return con;
    });
  }
}
