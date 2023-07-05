import 'package:flutter/material.dart';
import 'package:totk_recipe_proj/widgets/nav_bar.dart';
import 'package:totk_recipe_proj/models/material.dart';

class MaterialsPage extends StatefulWidget {
  @override
  _MaterialsPageState createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;
  String? materialCategoryQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(),
      appBar: AppBar(
        title: Text('Materials'),
        centerTitle: true,
        backgroundColor: Colors.red,
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
          Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 15.0),
            child: FilterDropdowns(
              selectedCookingMethod: materialCategoryQuery,
              onCookingMethodChanged: (value) {
                setState(() {
                  materialCategoryQuery = value;
                });
              },
            ),
          ),

          // Scrollable List of Recipes
          Expanded(
            child: TOTKMaterialList(
              searchQuery: searchQuery,
              selectedCookingMethod: materialCategoryQuery,
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
        hintText: 'Search by name or material category',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class TOTKMaterialList extends StatelessWidget {
  final String? searchQuery;
  final String? selectedCookingMethod;

  const TOTKMaterialList({
    required this.searchQuery,
    required this.selectedCookingMethod,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TOTKMaterial>>(
      // Parse the material CSV file, and
      // get back the material objects
      future: parseMaterialCSV(),
      builder: (context, snapshot) {
        // Check that we retrieved the data
        if (snapshot.hasData) {
          final List<TOTKMaterial> recipes = snapshot.data!;

          // Filter the materials
          final filteredRecipes = recipes.where((recipe) {
            return (searchQuery == null ||
                recipe.name.toLowerCase().contains(searchQuery!)) && (selectedCookingMethod == null ||
                recipe.materialCategory == selectedCookingMethod || selectedCookingMethod == 'All');
          }).toList();

          // Build the list view
          return ListView.builder(
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final TOTKMaterial recipe = filteredRecipes[index];
              return TOTKMaterialListItem(materials: recipe);
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

class TOTKMaterialListItem extends StatelessWidget {
  final TOTKMaterial materials;

  const TOTKMaterialListItem({required this.materials});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: materials.inventoryIcon,
      title: Text(materials.name),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(materials.caption),
          const SizedBox(height: 8.0),

          // Base hearts
          if (materials.heartsRecovered != '-')
            Row(
              children: [
                const Text(
                  'Base Hearts Recovered: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  materials.heartsRecovered,
                ),
              ],
            ),

          // Cooking Effect
          if (materials.cookingEffect != '-')
            Row(
              children: [
                const Text(
                  'Effect: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  materials.cookingEffect,
                ),
              ],
            ),

          // Material Category
          if (materials.materialCategory != '-')
            Row(
              children: [
                const Text(
                  'Material Category: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  materials.materialCategory,
                ),
              ],
            ),
        ],
      ),
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
          title: 'Sort by Material Category',
          value: selectedCookingMethod,
          items: const [
            'Fruit',
            'Mushroom',
            'Plant',
            'Meat',
            'Fish',
            'Insect',
            'Frog',
            'Lizard',
            'Enemy',
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
