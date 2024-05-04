import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'DetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> movies;

  const HomeScreen({Key? key, required this.movies}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<dynamic> filteredMovies = [];
  Map<dynamic, int> originalRankings = {};
  String searchQuery = "";
  Set<String> selectedGenres = {};

  @override
  void initState() {
    super.initState();
    filteredMovies = widget.movies;
    for (int i = 0; i < widget.movies.length; i++) {
      originalRankings[widget.movies[i]] = i + 1;
    }
  }

  void handleSearch(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filterMovies();
    });
  }

  void filterMovies() {
    filteredMovies = updateSearchQuery(searchQuery, widget.movies)
        .where((movie) => selectedGenres.isEmpty || movie['genre_names'].any(selectedGenres.contains))
        .toList();
  }

  String ordinal(int number) {
    if (number % 10 == 1 && number % 100 != 11) return '${number}st';
    if (number % 10 == 2 && number % 100 != 12) return '${number}nd';
    if (number % 10 == 3 && number % 100 != 13) return '${number}rd';
    return '${number}th';
  }

  void showGenreDialog() async {
    var genres = await fetchGenres();
    Set<String> tempSelectedGenres = Set<String>.from(selectedGenres);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Select Genres'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.clear_all),
                      title: const Text('Clear All'),
                      onTap: () {
                        setDialogState(() {
                          tempSelectedGenres.clear();
                        });
                      },
                    ),
                    ...genres.entries.map((entry) => CheckboxListTile(
                      title: Text(entry.value),
                      value: tempSelectedGenres.contains(entry.value),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value ?? false) {
                            tempSelectedGenres.add(entry.value);
                          } else {
                            tempSelectedGenres.remove(entry.value);
                          }
                        });
                      },
                    )).toList(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Filter'),
                  onPressed: () {
                    setState(() {
                      selectedGenres = tempSelectedGenres;
                      filterMovies();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top 10 Movies in the USA'),
        backgroundColor: Colors.white60,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: showGenreDialog,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: handleSearch,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for a movie',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                var movie = filteredMovies[index];
                int originalIndex = originalRankings[movie] ?? (index + 1);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white60,
                    child: ListTile(
                      leading: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                      ),
                      title: Text(
                        movie['title'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text('${formatDate(movie['release_date'])} - ${movie['genre_names'].join(', ')}\n${ordinal(originalIndex)} place'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(movie: movie),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}