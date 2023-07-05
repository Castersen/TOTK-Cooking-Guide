import 'package:flutter/material.dart';
import 'package:totk_recipe_proj/models/recipe.dart';
import 'package:totk_recipe_proj/widgets/nav_bar.dart';
import 'package:totk_recipe_proj/models/material.dart';

class CreativePage extends StatefulWidget {
  const CreativePage({Key? key}) : super(key: key);

  @override
  _CreativePageState createState() => _CreativePageState();
}

class _CreativePageState extends State<CreativePage> {
  final TextEditingController _searchController = TextEditingController();

  String? searchQuery;
  String? materialCategoryQuery;
  Recipe? recipe;
  List<TOTKMaterial> selectedMaterials = [];

  // Helper to add items to the array
  void _addMaterialToRecipe(TOTKMaterial material) {
    if(selectedMaterials.length == 5) { return; }
    setState(() {
      selectedMaterials.add(material);
    });
  }

  // Helper to clear the array
  void _removeMaterialFromRecipe(TOTKMaterial material) {
    setState(() {
      selectedMaterials.remove(material);
    });
  }

  // Helper to set recipe
  void _setRecipe(Recipe recipeCallBack) {
    setState(() {
      recipe = recipeCallBack;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(),
      appBar: AppBar(
        title: const Text('Creative'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 111, 83),
      ),
      body: Column(
        children: [

          // Recipe Section
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            child: RecipeItem(
              recipe: recipe,
            )
          ),

          // Grid of Selected Materials
          Container(
            height: 70,
            color: const Color.fromARGB(255, 217, 217, 217),
            child: IngredientsGrid(
              selectedMaterials: selectedMaterials,
              onMaterialTap: _removeMaterialFromRecipe,
            ),
          ),

          // Make Recipe Button
          Container(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 179, 63, 0),
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () async {
                Recipe recipe = await makeRecipe(selectedMaterials);
                _setRecipe(recipe);
              },
              child: const Text('Make Recipe'),
            ),
          ),

          // Clear Recipe Button
          Container(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 67, 14),
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                setState(() {
                  selectedMaterials.clear();
                });
              },
              child: const Text('Clear Ingredients'),
            ),
          ),

          // Search Bar
          Container(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
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
            padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
            child: FilterDropdownButton(
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
            child: MaterialsGrid(
              searchQuery: searchQuery,
              selectedCategory: materialCategoryQuery,
              onMaterialTap: _addMaterialToRecipe,
            ),
          ),
        ],
      ),
    );
  }
}

// Ingredients to grid to store ingredients used to craft recipes
class IngredientsGrid extends StatelessWidget {
  final List<TOTKMaterial> selectedMaterials;
  final Function(TOTKMaterial) onMaterialTap;

  const IngredientsGrid({
    required this.selectedMaterials,
    required this.onMaterialTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 30, right: 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columns
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: selectedMaterials.length,
      itemBuilder: (context, index) {
        final material = selectedMaterials[index];
        return IngredientsGridItem(material: material, onMaterialTap: onMaterialTap);
      },
    );
  }
}

// The individual ingredient item
class IngredientsGridItem extends StatelessWidget {
  final TOTKMaterial material;
  final Function(TOTKMaterial) onMaterialTap;

  const IngredientsGridItem({
    required this.material,
    required this.onMaterialTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector(
        onTap: () => onMaterialTap(material),
          child: Container(
            child: material.inventoryIcon,
          )
        )
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
        hintText: 'Search by Name or Material Category',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

// Grid of meterials to choose from
class MaterialsGrid extends StatelessWidget {
  final String? searchQuery;
  final String? selectedCategory;
  final Function(TOTKMaterial) onMaterialTap;

  const MaterialsGrid({
    required this.searchQuery,
    required this.selectedCategory,
    required this.onMaterialTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TOTKMaterial>>(
      // Parse the materials CSV file, and
      // get back the material objects
      future: parseMaterialCSV(),
      builder: (context, snapshot) {
        // Check that we have received the data
        if (snapshot.hasData) {
          final List<TOTKMaterial> materials = snapshot.data!;

          // Filter the materials
          final filteredMaterials = materials.where((testMaterial) {
            return (searchQuery == null || testMaterial.name.toLowerCase().contains(searchQuery!)
                || testMaterial.cookingTag1.replaceAll(' Cook', '').toLowerCase().contains(searchQuery!)) 
                && (selectedCategory == null || testMaterial.materialCategory == selectedCategory 
                || selectedCategory == 'All');
          }).toList();

          // Build the grid view
          return GridView.builder(
            padding: const EdgeInsets.all(20),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemCount: filteredMaterials.length,
            itemBuilder: (context, index) {
              final TOTKMaterial material = filteredMaterials[index];
              return MaterialGridItem(materials: material, onMaterialTap: onMaterialTap);
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

// Individual Material Item
class MaterialGridItem extends StatelessWidget {
  final TOTKMaterial materials;
  final Function(TOTKMaterial) onMaterialTap;

  const MaterialGridItem({
    required this.materials,
    required this.onMaterialTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: GestureDetector (
        // Call CB to filter material
        onTap: () => onMaterialTap(materials),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
      child: Tooltip(
        message: materials.name,
        child: Center(
          child: materials.inventoryIcon,
        )
      )
      ),
      )
    );
  }
}

// Used to help build the filter dropdown
class FilterDropdownButton extends StatelessWidget {
  final String? selectedCookingMethod;
  final ValueChanged<String?> onCookingMethodChanged;

  const FilterDropdownButton({
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

// ABRecipe
class RecipeItem extends StatelessWidget {
  final Recipe? recipe;

  const RecipeItem({this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: recipe?.inventoryIcon ?? const Icon(Icons.aspect_ratio_rounded),
      title: Text(recipe?.name ?? ''),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe?.caption ?? 'Create Recipes to Fill This!'),
          const SizedBox(height: 8.0),

          // Check that the recipe has an effect, if it does display it
          if (recipe?.effect != '-' && recipe != null)
            Row(
                children: [
                  const Text(
                    'Effect: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${recipe?.effect}',
                  )
                ],
              ),
          
          // Display the ingredients
          if (recipe?.requiredIngredients != null && recipe!.requiredIngredients.isNotEmpty)
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
                        recipe!.requiredIngredients.join(', '),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ],
      ),
    );
  }
}