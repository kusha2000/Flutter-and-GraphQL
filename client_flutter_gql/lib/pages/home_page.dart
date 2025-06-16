import 'package:client_flutter_gql/pages/add_book.dart';
import 'package:client_flutter_gql/pages/authors_page.dart';
import 'package:client_flutter_gql/pages/readers_page.dart';
import 'package:client_flutter_gql/pages/reviews_page.dart';
import 'package:client_flutter_gql/pages/book_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatelessWidget {
  final String fetchBooks = """
    query {
      books {
        id
        title
        author {
          id
          name
          bio
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("BookStore")),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'authors':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AuthorsPage()));
                  break;
                case 'readers':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ReadersPage()));
                  break;
                case 'reviews':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ReviewsPage()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'authors', child: Text('Authors')),
              const PopupMenuItem(value: 'readers', child: Text('Readers')),
              const PopupMenuItem(value: 'reviews', child: Text('Reviews')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddBook()));
        },
        child: const Icon(Icons.add),
      ),
      body: Query(
        options: QueryOptions(document: gql(fetchBooks)),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            print("Error: ${result.exception.toString()}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${result.exception.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: refetch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List books = result.data!['books'] ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No books available',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Add some books to get started',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              refetch?.call();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final author = book['author'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetailPage(bookId: book['id']),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'by ${author['name']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            author['bio'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
