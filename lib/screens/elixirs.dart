import 'package:flutter/material.dart';
import 'package:totk_recipe_proj/widgets/nav_bar.dart';
import 'package:totk_recipe_proj/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ElixirsPage extends StatefulWidget {
  @override
  _ElixirPageState createState() => _ElixirPageState();
}

class _ElixirPageState extends State<ElixirsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(),
      appBar: AppBar(
        title: Text('Elixirs'),
        centerTitle: true,
        backgroundColor: Colors.purple,
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

          // Scrollable List of Recipes
          Expanded(
            child: ElixirList(
              searchQuery: searchQuery,
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
        hintText: 'Search by name',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

// List of elixirs in the game
class ElixirList extends StatelessWidget {
  final String? searchQuery;

  const ElixirList({
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      // Parse the elixir csv file, and
      // get back the elixir objects
      future: parseElixir(),
      builder: (context, snapshot) {
        // Check that there is data
        if (snapshot.hasData) {
          final List<Recipe> elixirs = snapshot.data!;

          // Filter the elixirs
          final filteredRecipes = elixirs.where((elixirCB) {
            return (searchQuery == null ||
                elixirCB.name.toLowerCase().contains(searchQuery!));
          }).toList();

          // Build the list view
          return ListView.builder(
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final Recipe recipe = filteredRecipes[index];
              return ElixirListItem(recipe: recipe);
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

class ElixirListItem extends StatefulWidget {
  final Recipe recipe;

  const ElixirListItem({required this.recipe});

  @override
  _ElixirListItemState createState() => _ElixirListItemState();
}

class _ElixirListItemState extends State<ElixirListItem> {

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

          // Efect
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