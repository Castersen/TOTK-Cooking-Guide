import 'package:flutter/material.dart';
import 'package:totk_recipe_proj/widgets/nav_bar.dart';
import 'package:totk_recipe_proj/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;
  String? cookingMethodQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(),
      appBar: AppBar(
        title: Text('Recipes'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
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

          // Dropdown Menu
          Container(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0),
            child: FilterDropdowns(
              selectedCookingMethod: cookingMethodQuery,
              onCookingMethodChanged: (value) {
                setState(() {
                  cookingMethodQuery = value;
                });
              },
            ),
          ),

          // Scrollable List of Recipes
          Expanded(
            child: RecipeList(
              searchQuery: searchQuery,
              selectedCookingMethod: cookingMethodQuery,
              onSearchQueryChanged: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Search bar
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
class RecipeList extends StatelessWidget {
  final String? searchQuery;
  final String? selectedCookingMethod;
  final VoidCallback onSearchQueryChanged;


  const RecipeList({
    required this.searchQuery,
    required this.selectedCookingMethod,
    required this.onSearchQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      // Parse the recipes CSV file, and
      // get back the recipe objects
      future: parseRecipes(),
      builder: (context, snapshot) {
        // Check that we received the data
        if (snapshot.hasData) {
          final List<Recipe> recipes = snapshot.data!;

          // Filter the recipes
          final filteredRecipes = recipes.where((recipe) {
            return (searchQuery == null || recipe.name.toLowerCase().contains(searchQuery!)) &&
                (selectedCookingMethod == null || recipe.cookingMethod == selectedCookingMethod || selectedCookingMethod == 'All');
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

// Used to help build the filter dropdown
class FilterDropdowns extends StatelessWidget {
  final String? selectedCookingMethod;
  final ValueChanged<String?> onCookingMethodChanged;

  const FilterDropdowns({
    required this.selectedCookingMethod,
    required this.onCookingMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return 
        FilterDropdown(
          title: 'Sort by Cooking Method',
          value: selectedCookingMethod,
          items: const [
            'Cooking Pot',
            'Fire',
            'Hot Spring',
            'Freeze',
            'All',
          ],
          onChanged: onCookingMethodChanged,
        );
  }
}

// Builds the DropdownButton
class FilterDropdown extends StatelessWidget {
  final String title;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: value,
      onChanged: onChanged,

      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),

      hint: Text(title),
    );
  }
}
