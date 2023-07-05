import 'package:flutter/material.dart';

// Screens
import 'package:totk_recipe_proj/screens/creative.dart';
import 'package:totk_recipe_proj/screens/recipes.dart';
import 'package:totk_recipe_proj/screens/elixirs.dart';
import 'package:totk_recipe_proj/screens/materials.dart';
import 'package:totk_recipe_proj/screens/favorites.dart';
import 'package:totk_recipe_proj/screens/tips_and_tricks.dart';

class NavDrawerWidget extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color.fromARGB(255, 2, 87, 45),
        child: ListView(
          padding: padding,
          children: <Widget> [
            buildHeader(
              text: 'Zelda TOTK Recipe Guide'
            ),

            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Creative',
              icon: Icons.lightbulb,
              onClicked: () => selectedItem(context, 0),
            ),

            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Recipes',
              icon: Icons.book,
              onClicked: () => selectedItem(context, 1),
            ),

            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Elixirs',
              icon: Icons.science_outlined,
              onClicked: () => selectedItem(context, 2),
            ),

            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Materials',
              icon: Icons.account_tree_outlined,
              onClicked: () => selectedItem(context, 3),
            ),

            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Favorites',
              icon: Icons.bookmark,
              onClicked: () => selectedItem(context, 4),
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.white70),

            const SizedBox(height: 16),
            buildMenuItem(
              text: 'Tips and Tricks',
              icon: Icons.star_border,
              onClicked: () => selectedItem(context, 5),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildMenuItem({
  required String text,
  required IconData icon,
  VoidCallback? onClicked,
}) {
  const color = Colors.white;
  const hoverColor = Colors.white70;

  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(text, style: const TextStyle(color: color)),
    hoverColor: hoverColor,
    onTap: onClicked,
  );
}

Widget buildHeader({
  required String text,
}) {
    return Container(
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

void selectedItem(BuildContext context, int index) {
  // Close the navigation drawer before switching to new page
  Navigator.of(context).pop();

  switch (index) {
    case 0:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CreativePage(),
      ));
      break;
    case 1:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RecipePage(),
      ));
      break;
    case 2:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ElixirsPage(),
      ));
      break;
    case 3:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MaterialsPage(),
      ));
      break;
    case 4:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FavouritesPage(),
      ));
      break;
    case 5:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TipsAndTricksPage(),
      ));
      break;
  }
}