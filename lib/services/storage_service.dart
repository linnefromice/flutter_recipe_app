import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/adjustment_note.dart';
import '../models/master_recipe.dart';

class StorageService {
  static const _recipesKey = 'recipes';
  static const _notesKey = 'notes';

  Future<List<MasterRecipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_recipesKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => MasterRecipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecipes(List<MasterRecipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_recipesKey, jsonStr);
  }

  Future<List<AdjustmentNote>> loadNotes(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_notesKey}_$recipeId');
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => AdjustmentNote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNotes(String recipeId, List<AdjustmentNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString('${_notesKey}_$recipeId', jsonStr);
  }

  Future<void> deleteNotes(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_notesKey}_$recipeId');
  }
}
