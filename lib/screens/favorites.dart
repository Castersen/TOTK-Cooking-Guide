import 'package:flutter/material.dart';
import 'package:totk_recipe_proj/widgets/nav_bar.dart';
import 'package:totk_recipe_proj/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<FavouritesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;
  String? cookingMethodQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(),
      appBar: AppBar(
        title: Text('Favorites'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
          icon: Icon(Icons.refresh),
        onPressed: () {
          setState(() {}); // Refresh the view
            },
          ),
        ],
      ),
      body: Column(
        children: [

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              searchQuery: searchQuery,
              searchController: _searchController,
              onSearchQueryChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Scrollable List of Favorites
          Expanded(
            child: FavoritesList(
              searchQuery: searchQuery,
              selectedCookingMethod: cookingMethodQuery,
            ),
          ),
        ],
      ),
    );
  }
}

// Search Bar
class SearchBar extends StatelessWidget {
  final String? searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchQueryChanged;

  const SearchBar({
    required this.searchQuery,
    required this.searchController,
    required this.onSearchQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onSearchQueryChanged,
      decoration: const InputDecoration(
        hintText: 'Search by Name',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

// List of recipes in the game
class FavoritesList extends StatelessWidget {
  final String? searchQuery;
  final String? selectedCookingMethod;

  const FavoritesList({
    required this.searchQuery,
    required this.selectedCookingMethod,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      // Get the recipes from shared_prefencies
      future: getFavoriteRecipes(),
      builder: (context, snapshot) {
        // Check that we received the data
        if (snapshot.hasData) {
          final List<Recipe> recipes = snapshot.data!;

          // Filter the favorites
          final filteredRecipes = recipes.where((recipe) {
            return (searchQuery == null ||
                recipe.name.toLowerCase().contains(searchQuery!)) && (selectedCookingMethod == null ||
                recipe.cookingMethod == selectedCookingMethod || selectedCookingMethod == 'All');
          }).toList();

          // Build the list view
          return ListView.builder(
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final Recipe recipe = filteredRecipes[index];
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
        widget.recipe.isFavorite ? Icons.star : Icons.star_border,
        color: widget.recipe.isFavorite ? Colors.amber : null,
      ),
      onTap: () {
        toggleFavoriteStatus();
      },
    );
  }
}