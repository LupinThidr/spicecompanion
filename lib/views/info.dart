part of views;

class InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {

  Timer updateTimer;
  bool updateLock = false;

  String _disconnectMsg = "Disconnected.";
  String _avsModel = '';
  String _avsDest = '';
  String _avsSpec = '';
  String _avsRev = '';
  String _avsExt = '';
  String _avsServices = '';

  String _launcherVersion = '';
  String _launcherCompileDate;
  String _launcherCompileTime;
  DateTime _launcherSystemTime;
  List<String> _launcherArgs = [];

  num _memTotal = 1;
  num _memTotalUsed = 0;
  num _memUsed = 0;
  num _vmemTotal = 1;
  num _vmemTotalUsed = 0;
  num _vmemUsed = 0;

  _InfoViewState() {
    if (updateTimer != null)
      updateTimer.cancel();
    updateTimer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      infoTimerTick
    );

    // call it immediately for first update
    infoTimerTick(null);
  }

  @override
  void dispose() {
    if (updateTimer != null)
      updateTimer.cancel();
    super.dispose();
  }

  void infoTimerTick(Timer _) {
    if (updateLock) return;
    updateLock = true;
    ConnectionPool.inst.get().then((con) {
      var respAVS, respLauncher;

      return infoAVS(con).then((avs) {
        respAVS = avs;
        return infoLauncher(con);
      }).then((launcher) {
        respLauncher = launcher;
        return infoMemory(con);
      }).then((memory) {
        if (mounted) {
          setState(() {
            _avsModel = respAVS['model'] ?? "";
            _avsDest = respAVS['dest'] ?? "";
            _avsSpec = respAVS['spec'] ?? "";
            _avsRev = respAVS['rev'] ?? "";
            _avsExt = respAVS['ext'] ?? "";
            _avsServices = respAVS['services'] ?? "";

            _launcherVersion = respLauncher['version'] ?? "";
            _launcherCompileDate = respLauncher['compile_date'] ?? "";
            _launcherCompileTime = respLauncher['compile_time'] ?? "";
            try {
              _launcherSystemTime =
                  DateTime.parse((respLauncher['system_time'] ?? "") as String);
            } catch (FormatException) {
              _launcherSystemTime = null;
            }
            if (respLauncher['args'] != null)
              _launcherArgs = (respLauncher['args'] as List).cast<String>();
            else
              _launcherArgs = [""];

            _memTotal = memory['mem_total'] ?? 1;
            _memTotalUsed = memory['mem_total_used'] ?? 0;
            _memUsed = memory['mem_used'] ?? 0;
            _vmemTotal = memory['vmem_total'] ?? 1;
            _vmemTotalUsed = memory['vmem_total_used'] ?? 0;
            _vmemUsed = memory['vmem_used'] ?? 0;
          });
        }
      }).whenComplete(() {
        con.free();
      });
    }).catchError((e) {
      setState(() {
        _avsModel = _disconnectMsg;
        _avsDest = _disconnectMsg;
        _avsSpec = _disconnectMsg;
        _avsRev = _disconnectMsg;
        _avsExt = _disconnectMsg;
        _avsServices = _disconnectMsg;
        _launcherVersion = _disconnectMsg;
        _launcherCompileDate = null;
        _launcherCompileTime = null;
        _launcherSystemTime = null;
        _launcherArgs = [""];
        _memTotal = 1;
        _memTotalUsed = 0;
        _memUsed = 0;
        _vmemTotal = 1;
        _vmemTotalUsed = 0;
        _vmemUsed = 0;
      });
    }).whenComplete(() {
      updateLock = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          // AVS
          _createDisplay('Model', _avsModel),
          _createDisplay('Destination', _avsDest),
          _createDisplay('Specification', _avsSpec),
          _createDisplay('Revision', _avsRev),
          _createDisplay('Extension', _avsExt),
          _createDisplay('Services', _avsServices),

          Divider(),

          // Launcher Info
          _createDisplay('Version', _launcherVersion),
          _createDisplay(
            'Compile Time',
              _launcherCompileDate != null
              ? _getDateTimeFromGCC(_launcherCompileDate, _launcherCompileTime)
                : _disconnectMsg
          ),
          _createDisplay(
            'System Time',
            _launcherSystemTime != null
              ? _formatSystemTime(_launcherSystemTime.toLocal())
                : _disconnectMsg
          ),
          ListTile(
            title: Text('Launch Args (${_launcherArgs.length-1})'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text('Launch Args'),
                    ),
                    body: ListView(
                      children: _getArgList(_launcherArgs),
                    )
                  );
                }
              )
            )
          ),

          Divider(),

          // Memory Usage
          _createMemoryDisplay('Memory Usage', _memUsed, _memTotalUsed, _memTotal),
          _createMemoryDisplay('Virtual Memory', _vmemUsed, _vmemTotalUsed, _vmemTotal),
        ],
      ),
    );
  }
}

String _formatSystemTime(DateTime date) =>
  '${DateFormat('hh:mm:ssa').format(date)} on ${DateFormat.yMMMMd().format(date)}';

// guaranteed format, see: https://gcc.gnu.org/onlinedocs/cpp/Standard-Predefined-Macros.html
String _getDateTimeFromGCC(String date, String time) {
  var tmp = date.replaceAll('  ', ' ').split(' ');
  if (tmp.length < 3)
    return "";
  return '${tmp[2]} ${tmp[0]} ${tmp[1]} at $time';
}

// currently skips arg0 and provides a description for the rest from ./info_args (and a default for arg1)
// title is the argument followed by any additional associated parameters, subtitle is the description
List<ListTile> _getArgList(List<String> args) {
  List<ListTile> list = [];
  for (int i = 1; i < args.length; i++) {
    String option = args[i], desc = '';
    bool skipNext = false;

    if (info2PartArgsLookup.contains(args[i])) {
      option += ' ${args[i+1]}';
      skipNext = true;
    }

    if (infoArgsLookup.containsKey(args[i])) {
      desc = infoArgsLookup[args[i]];
    } else {
      if (args[i].startsWith('-'))
        desc = 'Unknown Argument ${args[i]}';
      else
        desc = 'Game Binary';
    }

    list.add(_createDisplay(option, desc));
    if (skipNext) i++;
  }
  return list;
}

Widget _createDisplay(String title, String desc) {
  return ListTile(
    title: Text(title),
    subtitle: Text(desc),
    onTap: () {}, // blank onTap adds the interact splash like in android settings's info
  );
}

// converts a bytecount to mebi and gibibytes (because multiples of 2 are 2 hard apparently)
String _getMiB(num bytes) => (bytes * 9.53674e-7).toStringAsFixed(2);
String _getGiB(num bytes) => (bytes * 9.31323e-10).toStringAsFixed(2);

Widget _createMemoryDisplay(String name, num used, num usedOutOfTotal, num total) {
  return ListTile(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(name),
        Row(
          children: <Widget>[
            Text(
              '${_getMiB(used)}MiB / ',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.lightGreen
              )
            ),
            Text(
              '${_getGiB(usedOutOfTotal)}GiB / ${_getGiB(total)}GiB',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              )
            )
          ],
        )
      ],
    ),
    subtitle: LinearProgressIndicator(
      value: usedOutOfTotal / total,
    ),
    onTap: () {}, // blank onTap adds the interact splash like in android settings's info
  );
}
