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

  /// updated story
  bool get isUpdated => _status == StoryStatus.updated;

  /// failed event
  bool get isFailed => _status == StoryStatus.failed;

  /// controller for titel
  late TextEditingController titleController;

  /// controller for creator
  late TextEditingController creatorController;

  /// controller for [Medium]
  late ValueNotifier<Medium> mediumController;

  /// Search Results controller
  late StreamController<List<Story>?> _search_results;

  /// representation of a story state for editing
  StoryState(this._service, {Story? story}) {
    _event = null;
    _status = StoryStatus.initial;
    _isLoading = false;
    _error = '';

    _story = story;

    titleController = TextEditingController(text: story?.title ?? '');
    creatorController = TextEditingController(text: story?.creator ?? '');
    mediumController =
        ValueNotifier(story?.medium ?? const Medium(name: 'Book'));
  }

  /// Value from controllers
  Story? get value => Story(
        title: titleController.text,
        medium: mediumController.value,
        creator: creatorController.text,
      );

  /// Update the story
  Future<void> update() async {
    _event = StoryEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.create(value!);

      _story = data.story;

      _status = StoryStatus.updated;
      titleController = TextEditingController(text: data.story.title);
      creatorController = TextEditingController(text: data.story.creator);
      mediumController = ValueNotifier(data.story.medium);
    } on DioError catch (e) {
      _status = StoryStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search for similar stories
  Future<void> search() async {
    _event = StoryEvent.search;
    _isLoading = true;

    notifyListeners();

    try {
      final data = await _service.search(value!);

      _search_results.sink.add(data.stories);
    } on DioError catch (e) {
      _status = StoryStatus.failed;
      _error = errorMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _search_results.close();
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
