import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../common/utils/error.dart';
import '../mediums/medium.dart';
import 'story.dart';

enum StoryEvent {
  update,
}

enum StoryStatus { initial, updated, failed }

enum StoryStateType { edit, create }

class StoryState extends ChangeNotifier {
  final StoryService _service;

  Story? _story;
  StoryEvent? _event;
  StoryStatus _status = StoryStatus.initial;
  bool _isLoading = false;
  String? _token;
  String _error = '';

  Story? get story => _story;
  StoryEvent? get event => _event;
  StoryStatus get status => _status;
  String? get token => _token;
  String get error => _error;

  bool get isLoading => _isLoading;
  bool get isUpdated => _status == StoryStatus.updated;
  bool get isFailed => _status == StoryStatus.failed;

  late TextEditingController titleController;
  late TextEditingController creatorController;
  late ValueNotifier<Medium> mediumController;

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

  Story? get value => Story(
        title: titleController.text,
        medium: mediumController.value,
        creator: creatorController.text,
      );

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
}
