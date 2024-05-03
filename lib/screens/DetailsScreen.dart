import 'package:flutter/material.dart';
import '../utils/utils.dart';

class DetailsScreen extends StatelessWidget {
  final dynamic movie;

  const DetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title']),
        backgroundColor: Colors.white60,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchCast(movie['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        movie['title'],
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Text(
                      formatDate(movie['release_date']),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      formatRating(movie['vote_average']),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('${movie['genre_names'].join(', ')}'),
                    if (snapshot.hasData)
                      Text(
                          'Cast',
                          style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(snapshot.data!.join(', ')),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(movie['overview']),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Failed to load cast details'));
          }
        },
      ),
    );
  }
}