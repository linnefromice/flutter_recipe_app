import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adjustment_note.dart';
import 'recipe_list_provider.dart';

final notesProvider = AsyncNotifierProvider.family<NotesNotifier,
    List<AdjustmentNote>, String>(NotesNotifier.new);

class NotesNotifier
    extends FamilyAsyncNotifier<List<AdjustmentNote>, String> {
  @override
  FutureOr<List<AdjustmentNote>> build(String arg) {
    return ref.read(storageServiceProvider).loadNotes(arg);
  }

  Future<void> addNote(AdjustmentNote note) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final updated = [note, ...current];
    await storage.saveNotes(arg, updated);
    state = AsyncData(updated);
  }

  Future<void> deleteNote(String noteId) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final updated = current.where((n) => n.id != noteId).toList();
    await storage.saveNotes(arg, updated);
    state = AsyncData(updated);
  }
}
