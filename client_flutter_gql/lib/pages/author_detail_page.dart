import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthorDetailPage extends StatelessWidget {
  final String authorId;

  const AuthorDetailPage({Key? key, required this.authorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fetchAuthorQuery = """
      query author(\$id: ID!) {
        author(id: \$id) {
          id
          name
          bio
          books {
            id
            title
            reviews {
              rating
            }
          }
        }
      }
    """;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Author Details"),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(fetchAuthorQuery),
          variables: {'id': authorId},
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final author = result.data?['author'];
          if (author == null) {
            return const Center(child: Text('Author not found'));
          }

          final books = author['books'] as List? ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Header Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                author['name'].toString().substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    author['name'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${books.length} ${books.length == 1 ? 'book' : 'books'}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Biography',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          author['bio'] ?? 'No biography available',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Books Section
                if (books.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Books (${books.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final reviews = book['reviews'] as List? ?? [];
                      final averageRating = reviews.isEmpty
                          ? 0.0
                          : reviews.fold(0.0, (sum, review) => sum + (review['rating'] as num)) / reviews.length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (reviews.isNotEmpty)
                                      Row(
                                        children: [
                                          Row(
                                            children: List.generate(5, (starIndex) {
                                              return Icon(
                                                starIndex < averageRating.round()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              );
                                            }),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${reviews.length} reviews',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      const Text(
                                        'No reviews yet',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}