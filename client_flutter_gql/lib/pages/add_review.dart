import 'package:client_flutter_gql/pages/reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddReview extends StatefulWidget {
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedBookId;
  String? _selectedReaderId;
  int _rating = 5;
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _readers = [];

  final String fetchBooksAndReadersQuery = """
    query {
      books {
        id
        title
        author {
          name
        }
      }
      readers {
        id
        name
        email
      }
    }
  """;

  final String addReviewMutation = """
    mutation addReview(\$bookId: ID!, \$readerId: ID!, \$content: String!, \$rating: Int!) {
      addReview(bookId: \$bookId, readerId: \$readerId, content: \$content, rating: \$rating) {
        id
        content
        rating
        book {
          title
        }
        reader {
          name
        }
      }
    }
  """;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Review"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Query(
          options: QueryOptions(document: gql(fetchBooksAndReadersQuery)),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              return Center(
                  child: Text(
                      'Error loading data: ${result.exception.toString()}'));
            }

            _books =
                List<Map<String, dynamic>>.from(result.data!['books'] ?? []);
            _readers =
                List<Map<String, dynamic>>.from(result.data!['readers'] ?? []);

            if (_books.isEmpty || _readers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(_books.isEmpty
                        ? 'No books available'
                        : 'No readers available'),
                    const Text('Please add books and readers first'),
                  ],
                ),
              );
            }

            return Mutation(
              options: MutationOptions(document: gql(addReviewMutation)),
              builder: (RunMutation runMutation, QueryResult? mutationResult) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Review Information',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedBookId,
                                decoration: const InputDecoration(
                                  labelText: "Select Book",
                                  prefixIcon: Icon(Icons.book),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                isExpanded: true,
                                items: _books.map((book) {
                                  return DropdownMenuItem<String>(
                                    value: book['id'],
                                    child: Text(
                                      '${book['title']} - by ${book['author']['name']}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedBookId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a book';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedReaderId,
                                decoration: const InputDecoration(
                                  labelText: "Select Reader",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                items: _readers.map((reader) {
                                  return DropdownMenuItem<String>(
                                    value: reader['id'],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          reader['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedReaderId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a reader';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Rating',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: _rating.toDouble(),
                                      min: 1,
                                      max: 5,
                                      divisions: 4,
                                      label: _rating.toString(),
                                      onChanged: (double value) {
                                        setState(() {
                                          _rating = value.round();
                                        });
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < _rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _contentController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: "Review Content",
                                  prefixIcon: Icon(Icons.rate_review),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter review content';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: mutationResult?.isLoading == true
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  runMutation({
                                    'bookId': _selectedBookId,
                                    'readerId': _selectedReaderId,
                                    'content': _contentController.text,
                                    'rating': _rating,
                                  });
                                }
                              },
                        child: mutationResult?.isLoading == true
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Add Review"),
                      ),
                      if (mutationResult?.hasException == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            color: Colors.red.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Error: ${mutationResult!.exception.toString()}',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ),
                        ),
                      if (mutationResult?.data != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green.shade700, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Review added successfully!',
                                    style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      _contentController.clear();
                                      setState(() {
                                        _selectedBookId = null;
                                        _selectedReaderId = null;
                                        _rating = 5;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewsPage(),
                                        ),
                                      );
                                    },
                                    child: const Text('Done'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
