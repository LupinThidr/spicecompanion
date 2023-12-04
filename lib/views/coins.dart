part of views;


class CoinsView extends StatefulWidget {

  @override
  _CoinsViewState createState() => _CoinsViewState();
}

class _CoinsViewState extends State<CoinsView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Insert Coin"),
            onTap: () {
              ConnectionPool.inst.get().then((con) {
                coinInsert(con, 1).whenComplete(() {
                  con.free();
                });
              }, onError: (e) {});
            },
          ),
          ListTile(
            title: Text("Insert 5 Coins"),
            onTap: () {
              ConnectionPool.inst.get().then((con) {
                coinInsert(con, 5).whenComplete(() {
                  con.free();
                });
              }, onError: (e) {});
            },
          ),
          ListTile(
            title: Text("Insert 10 Coins"),
            onTap: () {
              ConnectionPool.inst.get().then((con) {
                coinInsert(con, 10).whenComplete(() {
                  con.free();
                });
              }, onError: (e) {});
            },
          ),
        ],
      ),
    );
  }
}
