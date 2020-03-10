 *This method adds information to the Database*
 _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

 *This method check always if the Database are changed and changed the data in us list that shows our Database*
 _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

 *This method send the data to our Database*
 void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }
  
 *This element shows us the information obtained from the database and display it in ListTile* 
 FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  leading: Icon(Icons.message),
                  title: Text(items[index].title),
                  subtitle: Text(items[index].body),
                );
              },
            )

