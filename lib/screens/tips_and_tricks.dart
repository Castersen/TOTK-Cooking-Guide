import 'package:flutter/material.dart';
import 'package:totk_recipe_proj/widgets/nav_bar.dart';
import 'package:totk_recipe_proj/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsAndTricksPage extends StatefulWidget {
  @override
  _TipsAndTricks createState() => _TipsAndTricks();
}

class _TipsAndTricks extends State<TipsAndTricksPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToSection(double position) {
    _scrollController.animateTo(
      position,
      duration: Duration(milliseconds: 5),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(),
      appBar: AppBar(
        title: const Text('Tips and Tricks'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(137, 151, 0, 0),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Table of Contents',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                scrollToSection(0);
              },
              child: const Text(
                'Section 1 - Cooking Basics',
                style: TextStyle(fontSize: 16.0, decoration: TextDecoration.underline),
              ),
            ),

            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () {
                scrollToSection(800);
              },
              child: const Text(
                'Section 2 - How to use this app',
                style: TextStyle(fontSize: 16.0, decoration: TextDecoration.underline),
              ),
            ),

            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: () {
                scrollToSection(1500);
              },
              child: const Text(
                'Section 3 - Best Recipes',
                style: TextStyle(fontSize: 16.0, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 32.0),

            // *** Section1 ***
            const Text(
              'Section 1 - Introduction',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Cooking is a vital component of the game. In order to gain health, brew elixirs with'
              ' a wide variety of effects you must cook. There are also quests in the game and part'
              ' of the game that require you to cook specific meals, this is where this app will come'
              ' in handy.\n',
              style: TextStyle(fontSize: 16.0),
            ),

            const Text(
              '1.1 How to cook',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),

            const Text(
              'Enter the materials tab and tap \'A\' to add different ingredients.'
              ' Then find a cooking pot, or use a Zonai cooking pot (single use).'
              ' Walk over to the fire and throw them into the cooking pot!'
              ' Congrats, you have cooked your first meal.\n',
              style: TextStyle(fontSize: 16.0),
            ),
            Image.asset('assets/tips_and_tricks/materialsMenu.jpg'),
            const Text(
              'Materials Menu\n',
              style: TextStyle(fontSize: 14.0, decoration: TextDecoration.underline),
            ),

            Image.asset('assets/tips_and_tricks/cookingPot.jpg'),
            const Text(
              'Cooking Pot',
              style: TextStyle(fontSize: 14.0, decoration: TextDecoration.underline),
            ),

            // *** Section2 ***
            const SizedBox(height: 32.0),
            const Text(
              'Section 2 - Cooking Tips',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16.0),
            const Text(
              'Blood moons aren\'t so terrible! As annoying as it is to get caught'
              ' in the middle of a blood moon (especially after taking out enemies)'
              ' these are the best times to cook!\n',
              style: TextStyle(fontSize: 16.0),
            ),

            Image.asset('assets/tips_and_tricks/bloodMoon.jpg'),
            const Text(
              'Blood Moon',
              style: TextStyle(fontSize: 14.0, decoration: TextDecoration.underline),
            ),

            const SizedBox(height: 16.0),
            const Text(
              'During a Blood Moon, the chance to craft a great meal increases 100%'
              ' if you have spent some time finding some great materials wait for a Blood'
              ' Moon to come and then use your materials to cook up an amazing recipe!',
              style: TextStyle(fontSize: 16.0),
            ),

            const SizedBox(height: 32.0),
            const Text(
              'Section 3 - Recommended Recipes',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16.0),
            const Text(
              'Alright let\'s cut to the chase. Here I\'ll some outline the best'
              ' recipes in the game.\n\n'
              'Feel free to tap on any of these recipes to add them to your'
              ' your favorites.\n',
              style: TextStyle(fontSize: 16.0),
            ),

            // Scrollable List of Recipes
            RecipeList(),
          ],
        ),

      ),
    );
  }
}

// RecipeList
class RecipeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      // Parse the recipes CSV file, and
      // get back the recipe objects
      future: getTipsAndTricksRecipes(),
      builder: (context, snapshot) {
        // Check that we received the data
        if (snapshot.hasData) {
          final List<Recipe> recipes = snapshot.data!;

          // Build the list view
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final Recipe recipe = recipes[index];
              return RecipeListItem(recipe: recipe);
            },
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading recipes'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class RecipeListItem extends StatefulWidget {
  final Recipe recipe;

  const RecipeListItem({required this.recipe});

  @override
  _RecipeListItemState createState() => _RecipeListItemState();
}

class _RecipeListItemState extends State<RecipeListItem> {

    // Helper to store the recipe using shared_preferences
    Future<void> toggleFavoriteStatus() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        widget.recipe.isFavorite = !widget.recipe.isFavorite;
      });
      // Store the favorite status in shared_preferences
      await prefs.setBool(widget.recipe.name, widget.recipe.isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.recipe.inventoryIcon,
      title: Text(widget.recipe.name),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.recipe.caption),
          const SizedBox(height: 8.0),

          // Base hearts
          if (widget.recipe.baseHeartsRecovered != '-')
            Row(
              children: [
                const Text(
                  'Base Hearts Recovered: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.recipe.baseHeartsRecovered,
                ),
              ],
            ),

          // Effect
          if (widget.recipe.effect != '-')
            Row(
              children: [
                const Text(
                  'Effect: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.recipe.effect,
                ),
              ],
            ),

          // Cooking Method
          if (widget.recipe.cookingMethod != '-')
            Row(
              children: [
                const Text(
                  'Cooking Method: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.recipe.cookingMethod,
                ),
              ],
            ),

          // Ingredients
          if (widget.recipe.requiredIngredients.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                 'Required Ingredients: ',
                 style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                 child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Text(
                      widget.recipe.requiredIngredients.join(', '),
                    ),
                   ],
                  )
                 ),
               ],
              ),
          ],
      ),
      trailing: Icon(
        // Set the star icon
        widget.recipe.isFavorite ? Icons.star : Icons.star_border,
        color: widget.recipe.isFavorite ? Colors.amber : null,
      ),
      onTap: () {
        // Update the favorites
        toggleFavoriteStatus();
      },
    );
  }
}