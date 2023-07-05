import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totk_recipe_proj/models/material.dart';

class Recipe {
  String name;
  Image? inventoryIcon;
  String caption;
  List<String> requiredIngredients;
  String cookingMethod;
  String effect;
  String effectLevel;
  String effectDuration;
  String baseHeartsRecovered;
  String actorName;
  bool isFavorite;

  Recipe({
    required this.name,
    this.inventoryIcon,
    this.isFavorite = false,
    required this.caption,
    required this.requiredIngredients,
    required this.cookingMethod,
    required this.effect,
    required this.effectLevel,
    required this.effectDuration,
    required this.baseHeartsRecovered,
    required this.actorName,
  });

}

// Helper to generate the recipe objects
Future<Recipe> getRecipeObject(List<dynamic> row, String name) async {
    // Parse recipe data
    final String caption = row[2].replaceAll('\n', ' ');
    final String cookingMethod = row[8];
    final String effect = row[9];
    final String effectLevel = row[10].toString();
    final String effectDuration = row[11].toString();
    final String baseHeartsRecovered = row[12].toString();
    final String actorName = row[13];
    final Image inventoryIcon = Image.asset('assets/recipes/$actorName.png');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool favoriteStatus = prefs.getBool(name) ?? false;

    final List<String> requiredIngredients = [];
    for (var i = 3; i < 8; i++) {
      final ingredient = row[i].toString();
      if (ingredient != '-') {
        requiredIngredients.add(ingredient);
      }
    }

    // Create recipe
    return Recipe(
      name: name,
      caption: caption,
      isFavorite: favoriteStatus,
      requiredIngredients: requiredIngredients,
      cookingMethod: cookingMethod,
      effect: effect,
      effectLevel: effectLevel,
      effectDuration: effectDuration,
      baseHeartsRecovered: baseHeartsRecovered,
      actorName: actorName,
      inventoryIcon: inventoryIcon
    );

}

// Gets a list of recipes, not including elixirs
Future<List<Recipe>> parseRecipes() async {
  final String csvString = await rootBundle.loadString('assets/csv/recipe.csv');
  final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

  final List<Recipe> recipes = [];

  // Start from index 1 to skip the header row
  for (int i = 1; i < csvData.length; i++) {
    final List<dynamic> row = csvData[i];

    // Parse all of the data
    final String name = row[0];

    // Skip elixers
    if(name.toLowerCase().contains("elixir") || name.toLowerCase().contains("tonic")) {
      continue;
    }

    // Add to list
    recipes.add(await getRecipeObject(row, name));
  }

  return recipes;
}

// Get tips and tricks recipes
Future<List<Recipe>> getTipsAndTricksRecipes() async {
  final String csvString = await rootBundle.loadString('assets/csv/recipe.csv');
  final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

  final List<Recipe> recipes = [];

  // Start from index 1 to skip the header row
  for (int i = 1; i < csvData.length; i++) {
    final List<dynamic> row = csvData[i];

    // Parse all of the data
    final String name = row[0];

    // Skip elixers
    if(
      name != 'Hylian Tomato Pizza' &&
      name != 'Porgy Meunière' &&
      name != 'Apple Pie' && 
      name != 'Creamy Heart Soup' &&
      name != 'Hearty Elixir'
    ) {
      continue;
    }

    // Add to list
    recipes.add(await getRecipeObject(row, name));
  }

  return recipes;
}



// Get a list of elxirs
Future<List<Recipe>> parseElixir() async {
  final String csvString = await rootBundle.loadString('assets/csv/recipe.csv');
  final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

  final List<Recipe> elixirs = [];

  // Start from index 1 to skip the header row
  for (int i = 1; i < csvData.length; i++) {
    final List<dynamic> row = csvData[i];

    // Parse all of the data
    final String name = row[0];

    // Skip non elixirs
    if(!(name.toLowerCase().contains("elixir") || name.toLowerCase().contains("tonic"))) {
      continue;
    }

    // Add to list
    elixirs.add(await getRecipeObject(row, name));
  }

  return elixirs;
}

// Gets all cooking recipes
Future<List<Recipe>> getCookingRecipes() async {
  final String csvString = await rootBundle.loadString('assets/csv/recipe.csv');
  final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

  final List<Recipe> recipes = [];

  // Start from index 1 to skip the header row
  for (int i = 1; i < csvData.length; i++) {
    final List<dynamic> row = csvData[i];

    final String cookingMethod = row[8];
    final String name = row[0];
    // Only get the recipes that need a cooking pot
    if(cookingMethod != 'Cooking Pot') {
      continue;
    }

    // Add to list
    recipes.add(await getRecipeObject(row, name));
  }

  return recipes;
}

// Gets the favorite references from SharedPreferences
Future<List<Recipe>> getFavoriteRecipes() async {
  final String csvString = await rootBundle.loadString('assets/csv/recipe.csv');
  final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

  final List<Recipe> recipes = [];

  // Start from index 1 to skip the header row
  for (int i = 1; i < csvData.length; i++) {
    final List<dynamic> row = csvData[i];

    // Parse all of the data
    final String name = row[0];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool favoriteStatus = prefs.getBool(name) ?? false;
    // Skip if it is not a favorite
    if(!favoriteStatus) {
      continue;
    }

    // Parse recipe data
    final String caption = row[2].replaceAll('\n', ' ');
    final String cookingMethod = row[8];
    final String effect = row[9];
    final String effectLevel = row[10].toString();
    final String effectDuration = row[11].toString();
    final String baseHeartsRecovered = row[12].toString();
    final String actorName = row[13];
    final Image inventoryIcon = Image.asset('assets/recipes/$actorName.png');

    final List<String> requiredIngredients = [];
    for (var i = 3; i < 8; i++) {
      final ingredient = row[i].toString();
      if (ingredient != '-') {
        requiredIngredients.add(ingredient);
      }
    }

    // Create recipe
    final Recipe recipe = Recipe(
      name: name,
      caption: caption,
      isFavorite: favoriteStatus,
      requiredIngredients: requiredIngredients,
      cookingMethod: cookingMethod,
      effect: effect,
      effectLevel: effectLevel,
      effectDuration: effectDuration,
      baseHeartsRecovered: baseHeartsRecovered,
      actorName: actorName,
      inventoryIcon: inventoryIcon
    );

    // Add to list
    recipes.add(recipe);
  }

  return recipes;
}

/*
* Takes a list of ingredients and generates a recipe
*
* Algorithm:
* Go through all ingredients for a recipe, and compare with current set of
* ingredients, if there is a match remove ingredient from both.
* If the recipe array becomes empty it is a potential candidate,
* check other ingredients to make sure they do not contain items that
* would turn the recipe into dubious food.
*
*
* Extra care had to be taken for the or condtion where a recipe
* allowed for specific multiple ingredients to be used.
*
*
* After generating possible recipies, the one that contains the most
* ingredients is picked.
*/
Future<Recipe> makeRecipe(List<TOTKMaterial> ingredients) async {
  List<String> components = []; // Name i.e. Apple (Specific Ingredient)
  List<String> insectModifiers = []; // DefenseUp, StaminaRecover
  List<String> modifiers = []; // ResistHot, ResistCold
  List<String> categories = []; // CookInsect, CookFruit, CookMushroom (General)

  List<String> cookingTagCustom = []; // Tier 1 Meat, Bass
  List<String> cookingTagCustom2 = []; // Crab

  // Set the conditions
  for (TOTKMaterial ingredient in ingredients) { 
    components.add(ingredient.name);
    categories.add(ingredient.cookingTag1.replaceAll(" Cook", ""));

    if(ingredient.cookingEffect != '-') {
      modifiers.add(ingredient.cookingEffect);
    }

    if(ingredient.cookingTag1 == 'CookInsect') {
      insectModifiers.add(ingredient.cookingEffect);
    }


    if(ingredient.cookingTagCustom != '-') {
      cookingTagCustom.add(ingredient.cookingTagCustom);
    }

    if(ingredient.cookingTagCustom2 != '-') {
      cookingTagCustom2.add(ingredient.cookingTagCustom2);
    }
  }

  List<String> materialsJoined = [];
  materialsJoined.addAll(components);
  materialsJoined.addAll(insectModifiers);
  materialsJoined.addAll(modifiers);
  materialsJoined.addAll(categories);
  materialsJoined.addAll(cookingTagCustom);
  materialsJoined.addAll(cookingTagCustom2);

  List<Recipe> possibleMeals = [];
  List<Recipe> meals = await getCookingRecipes();

  // Find possible meals
  for(Recipe recipe in meals) {
    List<String> materialListCopy = List.of(materialsJoined);
    List<String> ingredientCopy = List.of(recipe.requiredIngredients);

    for(String ingredient in recipe.requiredIngredients) {
      if (ingredient.contains(' or ') || ingredient.contains(' / ')) {
        List<String> parts;
        if (ingredient.contains(' or ')) {
          parts = ingredient.split('or');
        } else {
          parts = ingredient.split('/');
        }
            
        // Trim whitespace from the split parts
        String ingredientOne = parts[0].trimRight();
        String ingredientTwo = parts[1].trimLeft();

        if(materialListCopy.contains(ingredientOne)) {
          materialListCopy.remove(ingredientOne);
          ingredientCopy.remove(ingredient);
          continue;
        }
        if(materialListCopy.contains(ingredientTwo)) {
          materialListCopy.remove(ingredientTwo);
          ingredientCopy.remove(ingredient);
          continue;
        }

        for(String materialIngredient in materialListCopy) {
          List<String> parts;
          if (materialIngredient.contains(' or ')) {
            parts = materialIngredient.split('or');
          } else if (materialIngredient.contains(' / ')) {
            parts = materialIngredient.split('/');
          } else {
            continue;
          }
              
          // Trim whitespace from the split parts
          String materialIngredientOne = parts[0].trimRight();
          String materialIngredientTwo = parts[1].trimLeft();

          if(materialIngredientOne == ingredientOne || materialIngredientOne == ingredientTwo) {
            materialListCopy.remove(materialIngredient);
            ingredientCopy.remove(ingredient);
            break;
          }

          if(materialIngredientTwo == ingredientOne || materialIngredientTwo == ingredientTwo) {
            materialListCopy.remove(materialIngredient);
            ingredientCopy.remove(ingredient);
            break;
          }
          }
      }

      if(materialListCopy.contains(ingredient)) {
        ingredientCopy.remove(ingredient);
        materialListCopy.remove(ingredient);
        continue;
      }
    }

    // Check that the remaining ingredients are valid
    if(materialListCopy.contains('Enemy') || materialListCopy.contains('Insect')) {
      if(!recipe.name.contains('Elixir')) {
        continue;
      }
    }

    if(materialListCopy.contains('Foreign') || materialListCopy.contains('Golem') || materialListCopy.contains('Ore')) {
      continue;
    }

    if(ingredientCopy.isEmpty) {
      possibleMeals.add(recipe);
    }
  }

  // Get the recipe, (recipe with most ingredients)
  Recipe? recipe;
  int maxIngredientCount = 0;
  for (Recipe meal in possibleMeals) {
    if(meal.requiredIngredients.length > maxIngredientCount) {
      maxIngredientCount = meal.requiredIngredients.length;
      recipe = meal;
    }
  }

  // Dubious food (there were no recipe matches)
  if(recipe == null) {
    for(Recipe meal in meals) {
      if(meal.name == 'Dubious Food') {
        recipe = meal;
        break;
      }
    }
  }

  return recipe!;
}