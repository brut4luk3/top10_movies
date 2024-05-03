import 'package:http/http.dart' as http;
import 'dart:convert';

var apiKey = '7b2836794d1187ad908231990fd4cbcc';

Future<Map<int, String>> fetchGenres() async {
  var url = 'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=en-US';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return Map.fromIterable(data['genres'], key: (e) => e['id'], value: (e) => e['name']);
  } else {
    throw Exception('Failed to load genres');
  }
}

Future<List<dynamic>> fetchMovies({String region = 'US'}) async {
  var genres = await fetchGenres();
  var url = 'https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&region=$region&language=en-US&page=1&sort_by=popularity.desc&api_key=$apiKey';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return data['results'].take(10).map((movie) {
      movie['genre_names'] = (movie['genre_ids'] as List).take(3).map((id) => genres[id] ?? 'Unknown').toList();
      return movie;
    }).toList();
  } else {
    throw Exception('Failed to load movies');
  }
}

Future<List<String>> fetchCast(int movieId) async {
  var url = 'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    List<dynamic> castList = data['cast'].take(3).toList();
    return castList.map((cast) => cast['name'] as String).toList();
  } else {
    throw Exception('Failed to load cast');
  }
}

List<dynamic> updateSearchQuery(String newQuery, List<dynamic> movies) {
  if (newQuery.isEmpty) {
    return movies;
  } else {
    return movies.where((movie) {
      return movie['title'].toLowerCase().contains(newQuery.toLowerCase());
    }).toList();
  }
}

String formatDate(String date) {
  return date.split('-').reversed.join('/');
}

String formatRating(double rating) {
  return "${rating.toStringAsFixed(1)} / 10";
}