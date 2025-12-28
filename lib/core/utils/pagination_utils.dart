// lib/ui/utils/pagination_utils.dart
List<T> paginate<T>(List<T> items, int page, int perPage) {
  final start = (page - 1) * perPage;
  if (start >= items.length) return [];
  final end = (start + perPage) > items.length ? items.length : (start + perPage);
  return items.sublist(start, end);
}
