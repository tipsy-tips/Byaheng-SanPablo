import 'package:flutter/material.dart';
import 'package:mapbox_navigation/screens/main_map.dart';

class RateRide extends StatelessWidget {
  const RateRide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Want to travel more?', style: Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const pointOfInterestMap()),
                ),
                child: const Text('Let\'s go!'),
              ),
              SizedBox(width: 10),
              // ElevatedButton(
              //   onPressed: () => _showConfirmationDialog(context),
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.red,
              //   ),
              //   child: const Text('Close App'),
              // ),
            ],
          ),
        ],
      ),
    );
  }

// Commented out the close app function and widget for provision
// Future<void> _showConfirmationDialog(BuildContext context) async {
//   return showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Close App'),
//         content: Text('Are you sure you want to close the app?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//               exit(0); // Terminate the app
//             },
//             child: Text('Yes'),
//           ),
//         ],
//       );
//     },
//   );
// }
}
