// https://medium.com/@nitishk72/form-validation-in-flutter-d762fbc9212c
// https://stackoverflow.com/questions/53424916/textfield-validation-in-flutter
// https://flutter.dev/docs/development/ui/layout
// https://medium.com/leclevietnam/flutter-t%E1%BB%95ng-h%E1%BB%A3p-ph%C3%ADm-t%E1%BA%AFt-c%E1%BB%A7a-visual-studio-6443e5b4cede
// https://inducesmile.com/google-flutter/how-to-update-data-in-firestore-database-in-flutter/
// https://medium.com/flutter-community/building-a-chat-app-with-flutter-and-firebase-from-scratch-9eaa7f41782e
// https://codelabs.developers.google.com/codelabs/flutter-firebase/#10
// https://flutter.dev/docs/development/data-and-backend/firebase
// https://pub.dev/packages/cloud_firestore

// class MyHomePage extends StatefulWidget {
//   @override
//   MyHomePageState createState() {
//     return new MyHomePageState();
//   }
// }

// class MyHomePageState extends State<MyHomePage> {
//   final _text = TextEditingController();
//   bool _validate = false;

//   @override
//   void dispose() {
//     _text.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TextField Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Error Showed if Field is Empty on Submit button Pressed'),
//             TextField(
//               controller: _text,
//               decoration: InputDecoration(
//                 labelText: 'Enter the Value',
//                 errorText: _validate ? 'Value Can\'t Be Empty' : null,
//               ),
//             ),
//             RaisedButton(
//               onPressed: () {
//                 setState(() {
//                   _text.text.isEmpty ? _validate = true : _validate = false;
//                 });
//               },
//               child: Text('Submit'),
//               textColor: Colors.white,
//               color: Colors.blueAccent,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }