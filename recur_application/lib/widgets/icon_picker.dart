import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  final Function(IconData) onIconSelected;

  IconPicker({required this.onIconSelected});

  // Razširjen seznam ikon
  final List<IconData> allIcons = [
    Icons.access_alarm,
    Icons.accessibility,
    Icons.account_balance,
    Icons.account_box,
    Icons.add_a_photo,
    Icons.add_shopping_cart,
    Icons.airline_seat_flat,
    Icons.airplanemode_active,
    Icons.alarm,
    Icons.album,
    Icons.android,
    Icons.arrow_back,
    Icons.arrow_forward,
    Icons.beach_access,
    Icons.bluetooth_audio,
    Icons.book,
    Icons.border_color,
    Icons.brush,
    Icons.bug_report,
    Icons.cake,
    Icons.calendar_today,
    Icons.camera_alt,
    Icons.chat,
    Icons.check,
    Icons.child_friendly,
    Icons.cloud,
    Icons.code,
    Icons.color_lens,
    Icons.comment,
    Icons.computer,
    Icons.directions_bike,
    Icons.directions_bus,
    Icons.directions_run,
    Icons.directions_walk,
    Icons.electric_bike,
    Icons.email,
    Icons.favorite,
    Icons.fitness_center,
    Icons.flight,
    Icons.gamepad,
    Icons.headset,
    Icons.healing,
    Icons.home,
    Icons.hourglass_full,
    Icons.image,
    Icons.invert_colors,
    Icons.key,
    Icons.keyboard,
    Icons.lightbulb,
    Icons.local_cafe,
    Icons.local_dining,
    Icons.local_drink,
    Icons.local_fire_department,
    Icons.local_hospital,
    Icons.local_movies,
    Icons.local_offer,
    Icons.local_pharmacy,
    Icons.local_pizza,
    Icons.local_play,
    Icons.local_shipping,
    Icons.location_city,
    Icons.lock,
    Icons.map,
    Icons.music_note,
    Icons.pets,
    Icons.phone,
    Icons.photo_camera,
    Icons.pool,
    Icons.sailing,
    Icons.school,
    Icons.send,
    Icons.shopping_bag,
    Icons.shopping_cart,
    Icons.smartphone,
    Icons.sports,
    Icons.sports_basketball,
    Icons.sports_football,
    Icons.star,
    Icons.store,
    Icons.theater_comedy,
    Icons.train,
    Icons.videogame_asset,
    Icons.wb_sunny,
    Icons.wifi,
    Icons.work,
    Icons.yard,
    Icons.zoom_out_map,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select an Icon",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // Povečamo število stolpcev
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: allIcons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      onIconSelected(allIcons[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        allIcons[index],
                        size: 24,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}