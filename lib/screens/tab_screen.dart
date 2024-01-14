import 'package:flutter/material.dart';
import 'package:flutter_meals/models/filter.dart';
import 'package:flutter_meals/providers/favorites_provider.dart';
import 'package:flutter_meals/providers/meals_provider.dart';
import 'package:flutter_meals/screens/categories_screen.dart';
import 'package:flutter_meals/screens/filters_screen.dart';
import 'package:flutter_meals/screens/meals_screen.dart';
import 'package:flutter_meals/widgets/main_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kInitialFilter = {
  Filter.glutenFree: false,
  Filter.vegan: false,
  Filter.vegetarian: false,
  Filter.lactoseFree: false,
};

class TabScreen extends ConsumerStatefulWidget {
  const TabScreen({super.key});

  @override
  ConsumerState<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends ConsumerState<TabScreen> {
  int _selectedPageIndex = 0;
  Map<Filter, bool> _selectedFilter = kInitialFilter;

  void _selectPage(int index) {
    setState(() => _selectedPageIndex = index);
  }

  void _selectScreen(String screen) async {
    Navigator.of(context).pop();
    switch (screen) {
      case 'filters':
        final result = await Navigator.of(context).push<Map<Filter, bool>>(
          MaterialPageRoute(
            builder: (context) => FiltersScreen(
              currentFilter: _selectedFilter,
            ),
          ),
        );

        setState(() {
          _selectedFilter = result ?? kInitialFilter;
        });
        break;
      default:
        break;
    }

    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final favoriteMeals = ref.watch(favoriteMealsProvider);

    final availableMeals = meals.where((meal) {
      if (_selectedFilter[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFilter[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFilter[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      if (_selectedFilter[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      return true;
    }).toList();

    Widget activePage = CategpriesScreen(
      availableMeals: availableMeals,
    );
    String activePageTitle = 'Categories';

    switch (_selectedPageIndex) {
      case 1:
        activePage = MealsScreen(
          meals: favoriteMeals,
        );
        activePageTitle = 'Favorites';
        break;
      default:
        activePage = CategpriesScreen(
          availableMeals: availableMeals,
        );
        activePageTitle = 'Categories';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      body: activePage,
      drawer: MainDrawer(onSelectScreen: _selectScreen),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _selectPage(index);
        },
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}
