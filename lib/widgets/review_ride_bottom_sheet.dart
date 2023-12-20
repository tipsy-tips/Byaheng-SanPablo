import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../screens/turn_by_turn.dart';


Widget reviewRideBottomSheet(
    BuildContext context, String distance, String dropOffTime, Map<String, dynamic> poi) {

  return Positioned(
    bottom: 0,
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current Location ➡ ${poi['name']}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.indigo)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    tileColor: Colors.grey[200],
                    leading: const Image(
                        image: AssetImage('assets/image/sport-car.png'),
                        height: 50,
                        width: 50),
                    title: Text(poi['name'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('$distance km, $dropOffTime travel time'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Start turn-by-turn navigation
                    startNavigation(context, poi);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Start your ride now'),
                    ],
                  ),
                ),
              ]
          ),
        ),
      ),
    ),
  );
}

void startNavigation(BuildContext context, Map<String, dynamic> poi) {
  // Extract the destination coordinates
  final destination = LatLng(
    poi['coordinates']['latitude'],
    poi['coordinates']['longitude'],
  );

  // Navigate to the TurnByTurn screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TurnByTurn(
        destination: destination,
      ),
    ),
  );
}
