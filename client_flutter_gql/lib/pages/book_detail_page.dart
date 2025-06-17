import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fetchBookQuery = """
      query book(\$id: ID!) {
        book(id: \$id) {
          id
          title
          author {
            id
            name
            bio
          }
          reviews {
            id
            content
            rating
            reader {
              name
            }
          }
        }
      }
    """;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Details"),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(fetchBookQuery),
          variables: {'id': bookId},
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text('Error: ${result.exception.toString()}'));
          }

          final book = result.data!['book'];
          if (book == null) {
            return const Center(child: Text('Book not found'));
          }

          final author = book['author'];
          final reviews = book['reviews'] as List;
          final averageRating = reviews.isEmpty
              ? 0.0
              : reviews.fold(
                      0, (sum, review) => sum + (review['rating'] as int)) /
                  reviews.length;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Header Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'by ${author['name']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          author['bio'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (reviews.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < averageRating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${averageRating.toStringAsFixed(1)} (${reviews.length} reviews)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Reviews Section
                if (reviews.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Reviews (${reviews.length})',
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
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final rating = review['rating'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review['reader']['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['content'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.rate_review_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text(
                            'No reviews yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
