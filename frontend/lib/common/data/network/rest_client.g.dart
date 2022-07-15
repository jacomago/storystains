// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    baseUrl ??= 'http://127.0.0.1:8080/api';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<WrappedStory> createStory(newStory) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(newStory.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<WrappedStory>(
            Options(method: 'POST', headers: _headers, extra: _extra)
                .compose(_dio.options, '/stories',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = WrappedStory.fromJson(_result.data!);
    return value;
  }

  @override
  Future<StoriesResp> searchStories(
      {creator, medium, title, limit = 10, offset = 0}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'creator': creator,
      r'medium': medium,
      r'title': title,
      r'limit': limit,
      r'offset': offset
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<StoriesResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/stories',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = StoriesResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ReviewResp> createReview(newReview) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(newReview.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewResp>(
            Options(method: 'POST', headers: _headers, extra: _extra)
                .compose(_dio.options, '/reviews',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ReviewResp> updateReview(username, slug, updatedReview) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(updatedReview.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewResp>(
            Options(method: 'PUT', headers: _headers, extra: _extra)
                .compose(_dio.options, '/reviews/${username}/${slug}',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ReviewResp> readReview(username, slug) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/reviews/${username}/${slug}',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteReview(username, slug) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    await _dio.fetch<void>(_setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(_dio.options, '/reviews/${username}/${slug}',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    return null;
  }

  @override
  Future<ReviewEmotionResp> createReviewEmotion(
      username, slug, newReviewEmotion) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(newReviewEmotion.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewEmotionResp>(
            Options(method: 'POST', headers: _headers, extra: _extra)
                .compose(_dio.options, '/reviews/${username}/${slug}/emotions',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewEmotionResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ReviewEmotionResp> updateReviewEmotion(
      username, slug, position, updatedReviewEmotion) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(updatedReviewEmotion.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewEmotionResp>(
            Options(method: 'PUT', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/reviews/${username}/${slug}/emotions/${position}',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewEmotionResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ReviewEmotionResp> readReviewEmotion(username, slug, position) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewEmotionResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options,
                    '/reviews/${username}/${slug}/emotions/${position}',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewEmotionResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteReviewEmotion(username, slug, position) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    await _dio.fetch<void>(_setStreamType<void>(Options(
            method: 'DELETE', headers: _headers, extra: _extra)
        .compose(
            _dio.options, '/reviews/${username}/${slug}/emotions/${position}',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    return null;
  }

  @override
  Future<UserResp> addUser(addUser) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(addUser.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserResp>(
            Options(method: 'POST', headers: _headers, extra: _extra)
                .compose(_dio.options, '/signup',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<UserResp> loginUser(login) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(login.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserResp>(
            Options(method: 'POST', headers: _headers, extra: _extra)
                .compose(_dio.options, '/login',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> deleteUser() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    await _dio.fetch<void>(_setStreamType<void>(
        Options(method: 'DELETE', headers: _headers, extra: _extra)
            .compose(_dio.options, '/users',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    return null;
  }

  @override
  Future<UserResp> getCurrentUser() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<UserResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, 'user',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = UserResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ReviewsResp> getReviews(
      {username, creator, medium, title, limit = 10, offset = 0}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'username': username,
      r'creator': creator,
      r'medium': medium,
      r'title': title,
      r'limit': limit,
      r'offset': offset
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ReviewsResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/reviews',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ReviewsResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<EmotionsResp> getEmotions() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<EmotionsResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/emotions',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = EmotionsResp.fromJson(_result.data!);
    return value;
  }

  @override
  Future<MediumsResp> getMediums() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<MediumsResp>(
            Options(method: 'GET', headers: _headers, extra: _extra)
                .compose(_dio.options, '/mediums',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = MediumsResp.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
