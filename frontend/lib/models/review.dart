class Review {
  final String slug;
  final String title;
  final String review;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Review(
      {required this.slug,
      required this.title,
      required this.review,
      required this.createdAt,
      required this.modifiedAt});

  Review.fromJson(Map<dynamic, dynamic> json)
      : slug = json['slug']?.toString() ?? '',
        title = json['title']?.toString() ?? '',
        review = json['review']?.toString() ?? '',
        createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
        modifiedAt = DateTime.tryParse(json['modified_at']?.toString() ?? '') ??
            DateTime.now();

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'review': review,
        'created_at': createdAt.toIso8601String(),
        'modified_at': modifiedAt.toIso8601String()
      };
}

class EditReview {
  final String title;
  final String review;

  EditReview({required this.title, required this.review});

  EditReview.fromJson(Map<dynamic, dynamic> json)
      : title = json['title']?.toString() ?? '',
        review = json['review']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'title': title,
        'review': review,
      };
}
