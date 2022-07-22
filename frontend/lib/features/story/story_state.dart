import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../common/utils/error.dart';
import '../mediums/medium.dart';
import 'story.dart';

/// events on [Story]
enum StoryEvent {
  /// Update the [Story]
  update,

  /// Search for [Story]s
  search,
}

/// status of state
enum StoryStatus {
  /// load
  initial,

  /// updated to api
  updated,

  /// failed action
  failed
}

/// state type
enum StoryStateType {
  /// Editing the review
  edit,

  /// creating a new review (not in api)
  create,
}

/// representation of a story state for editing
class StoryState extends ChangeNotifier {
  final StoryService _service;

  Story? _story;
  StoryEvent? _event;
  StoryStatus _status = StoryStatus.initial;
  bool _isLoading = false;
  String _error = '';

  /// controller for titel
  late TextEditingController titleController;

  /// controller for creator
  late TextEditingController creatorController;

  /// controller for [Medium]
  late ValueNotifier<Medium?> mediumController;

  /// Search Results controller
  late StreamController<List<Story>?> searchResults;

  /// loaded story
  Story? get story => _story;

  /// current action
  StoryEvent? get event => _event;

  /// current status
  StoryStatus get status => _status;

  /// error message
  String get error => _error;

  /// currently loading
  bool get isLoading => _isLoading;

  /// currently searching
  bool get isSearching => _event == StoryEvent.search;

  /// updated story
  bool get isUpdated => _status == StoryStatus.updated;

  /// failed event
  bool get isFailed => _status == StoryStatus.failed;

  /// representation of a story state for editing
  StoryState(this._service, {Story? story, StoryQuery? query}) {
    _event = null;
    _status = StoryStatus.initial;
    _isLoading = false;
    _error = '';

    _story = story;

    titleController = TextEditingController(text: story?.title ?? query?.title);
    creatorController =
        TextEditingController(text: story?.creator ?? query?.creator);
    mediumController = ValueNotifier(story?.medium ?? query?.medium);
    searchResults = StreamController<List<Story>?>.broadcast();
  }

  /// Value from controllers
  Story get value => Story(
        title: titleController.text,
        medium: mediumController.value ?? Medium.mediumDefault,
        creator: creatorController.text,
      );

  /// Query from controllers
  StoryQuery get query => StoryQuery(
        title: titleController.text.isEmpty ? null : titleController.text,
        medium: mediumController.value,
        creator: creatorController.text.isEmpty ? null : creatorController.text,
      );

  /// Clear the value from the controller
  void clear() {
    titleController.clear();
    creatorController.clear();
    mediumController.value = Medium.mediumDefault;
  }

  void _setControllers(Story story) {
    titleController.text = story.title;
    creatorController.text = story.creator;
    mediumController.value = story.medium;
  }

  /// Update the story
  Future<void> update() async {
    _event = StoryEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.create(value);

      _story = data.story;

      _status = StoryStatus.updated;
      _setControllers(data.story);
    } on DioError catch (e) {
      _status = StoryStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search for similar stories
  Future<void> search() async {
    final searchValue = query;

    if (searchValue.title == null && searchValue.creator == null) {
      searchResults.sink.add(null);

      return;
    }

    _event = StoryEvent.search;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.search(query);

      searchResults.sink.add(data.stories);
    } on DioError catch (e) {
      _status = StoryStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Pick a story from the search list to be assigned
  void pickStory(Story story) {
    _setControllers(story);
    _endSearch();
  }

  /// Stop searching for stories
  void _endSearch() {
    _event = null;
    searchResults.sink.add(null);
    notifyListeners();
  }

  @override
  void dispose() {
    searchResults.close();
    titleController.dispose();
    creatorController.dispose();
    mediumController.dispose();
    _story = null;
    _event = null;
    _status = StoryStatus.initial;
    _isLoading = false;
    _error = '';
    super.dispose();
  }
}
