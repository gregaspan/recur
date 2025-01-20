import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  final Function(IconData) onIconSelected;

  IconPicker({required this.onIconSelected});

  final List<IconData> allIcons = [
  // Zdravje in fitnes
  Icons.favorite,
  Icons.fitness_center,
  Icons.directions_run,
  Icons.self_improvement,
  Icons.local_hospital,
  Icons.healing,
  Icons.accessibility_new,
  Icons.monitor_heart,
  Icons.bloodtype,
  Icons.sick,
  Icons.spa, // Sprostitev

  // Šport in gibanje
  Icons.sports,
  Icons.sports_basketball,
  Icons.sports_football,
  Icons.sports_tennis,
  Icons.sports_volleyball,
  Icons.sports_martial_arts,
  Icons.sports_handball,
  Icons.sports_kabaddi,
  Icons.directions_bike,
  Icons.pool,
  Icons.rowing, // Veslanje
  Icons.snowboarding, // Zimski športi
  Icons.sailing, // Jadranje

  // Delo in produktivnost
  Icons.work,
  Icons.work_outline,
  Icons.school,
  Icons.code,
  Icons.create,
  Icons.book,
  Icons.laptop,
  Icons.assignment,
  Icons.event_note, // Planiranje
  Icons.task_alt, // Opravljene naloge
  Icons.lightbulb, // Ideje ali učenje
  Icons.fact_check, // Preverjanje dejstev

  // Sprostitev in hobiji
  Icons.movie,
  Icons.headset,
  Icons.videogame_asset,
  Icons.brush,
  Icons.camera_alt,
  Icons.palette,
  Icons.local_florist,
  Icons.casino, // Igre na srečo ali zabava
  Icons.music_note, // Glasba
  Icons.theater_comedy, // Gledališče
  Icons.bookmark, // Branje knjig

  // Hrana in pijača
  Icons.local_dining,
  Icons.local_drink,
  Icons.local_cafe,
  Icons.local_pizza,
  Icons.cake,
  Icons.emoji_food_beverage, // Pijače
  Icons.fastfood, // Hitri prigrizki
  Icons.icecream, // Sladice
  Icons.kitchen, // Kuhanje doma
  Icons.dining, // Jesti zunaj

  // Potovanja in transport
  Icons.flight,
  Icons.train,
  Icons.directions_walk,
  Icons.directions_car,
  Icons.explore,
  Icons.hiking, // Pohodništvo
  Icons.map, // Raziskovanje

  // Družbeni habit
  Icons.group,
  Icons.chat,
  Icons.phone,
  Icons.email,
  Icons.volunteer_activism,
  Icons.celebration, // Praznovanje
  Icons.group_work, // Delo v skupini
  Icons.connect_without_contact, // Ohranitev stikov

  // Spanje in sprostitev
  Icons.bed,
  Icons.wb_sunny,
  Icons.nightlight_round,
  Icons.self_improvement,
  Icons.bathroom, // Večerna rutina
  Icons.alarm, // Zbujanje ob določeni uri
  Icons.energy_savings_leaf, // Varčevanje z energijo

  // Organizacija in finance
  Icons.account_balance,
  Icons.attach_money,
  Icons.calendar_today,
  Icons.check,
  Icons.list,
  Icons.receipt_long, // Sledenje stroškom
  Icons.wallet, // Upravljanje proračuna
  Icons.event, // Dogodki
  Icons.hourglass_empty, // Upravljanje časa

  // Okolje in navade
  Icons.eco,
  Icons.cleaning_services,
  Icons.recycling,
  Icons.wash,
  Icons.nature, // Okolje
  Icons.park, // Narava
  Icons.shower, // Higiena
  Icons.grass, // Naravne navade
  Icons.water, // Pitje vode ali skrb za rastline
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