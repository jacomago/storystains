import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:storystains/common/data/network/api_exception.dart';
import 'package:storystains/common/utils/error.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/story/story.dart';

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
  bool _isEdit = false;

  Story? get story => _story;
  StoryEvent? get event => _event;
  StoryStatus get status => _status;
  String? get token => _token;
  String get error => _error;

  bool get isEdit => _isEdit;

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
    _isEdit = story != null;
    titleController = TextEditingController(text: story?.title ?? "");
    creatorController = TextEditingController(text: story?.creator ?? "");
    mediumController = ValueNotifier(story?.medium ?? Medium(name: 'Book'));
  }

  edit() {
    _isEdit = true;
    notifyListeners();
  }

  unEdit() {
    _isEdit = false;
    notifyListeners();
  }

  Future update() async {
    _event = StoryEvent.update;
    _isLoading = true;

    notifyListeners();

    try {
      final title = titleController.text;
      final creator = creatorController.text;
      final medium = mediumController.value;

      final data = await _service.create(title, creator, medium);

      if (data is WrappedStory) {
        _story = data.story;

        _status = StoryStatus.updated;
        titleController = TextEditingController(text: data.story.title);
        creatorController = TextEditingController(text: data.story.creator);
        mediumController = ValueNotifier(data.story.medium);
      } else {
        final e = StatusCodeException.exception(data);
        throw e;
      }
    } on DioError catch (e) {
      _status = StoryStatus.failed;
      _error = errorMessage(e);
    } catch (e) {
      _status = StoryStatus.failed;
    }

    _isLoading = false;
    notifyListeners();
  }
}
