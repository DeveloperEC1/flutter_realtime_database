import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class RealtimeDatabaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Realtime Database',
      theme: ThemeData.light(),
      home: RealtimeDatabase(),
    );
  }
}

class RealtimeDatabase extends StatefulWidget {
  @override
  RealtimeDatabaseState createState() => RealtimeDatabaseState();
}

class RealtimeDatabaseState extends State<RealtimeDatabase> {
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  int num = 0;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRef = database.reference().child('items');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      num = num + 1;
      itemRef.child('path' + num.toString()).set(item.toJson());
    }
  }

  _update() {
    itemRef.child('path1').update({'title': 'updated', 'body': 'updated'});
  }

  _delete() {
    itemRef.child('path1').remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realtime Database'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text("Realtime Database",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.title = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => item.body = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        handleSubmit();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.update),
                      onPressed: () {
                        _update();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _delete();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                    leading: Icon(Icons.message),
                    title: Text(items[index].title),
                    subtitle: Text(items[index].body));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Item {
  String key;
  String title;
  String body;

  Item(this.title, this.body);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"],
        body = snapshot.value["body"];

  toJson() {
    return {
      "title": title,
      "body": body,
    };
  }
}
