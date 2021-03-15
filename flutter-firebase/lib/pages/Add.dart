import 'package:flutter/material.dart';

// ugly hack
// I'll use callback to update parent's state before a better solution is found
// the callback will mutate a local variable
// and after `await` the data should've been updated
class UglyHackForm extends StatefulWidget {
  final Icon icon;
  final String label;
  final void Function(String) callback;

  const UglyHackForm(
      {Key key,
      @required this.icon,
      @required this.label,
      @required this.callback})
      : super(key: key);

  @override
  _UglyHackFormState createState() => _UglyHackFormState();
}

class _UglyHackFormState extends State<UglyHackForm> {
  String data;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        icon: widget.icon,
        labelText: widget.label,
      ),
      onChanged: (text) => widget.callback(text),
    );
  }
}

class Add extends StatelessWidget {
  // final Function(String) callback;

  // FIXME: This is really so ugly
  const Add({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void Function(String) callback = ModalRoute.of(context).settings.arguments;

    var body = Center(
        child: UglyHackForm(
      icon: Icon(Icons.account_circle),
      label: 'Input category',
      callback: callback,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Add new entry'),
      ),
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Text('Enter'),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
