import 'package:client_flutter_gql/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedAuthorId;
  List<Map<String, dynamic>> _authors = [];

  final String fetchAuthorsQuery = """
    query {
      authors {
        id
        name
        bio
      }
    }
  """;

  final String addBookMutation = """
    mutation addMutation(\$title: String!, \$authorId: ID!) {
      addBook(title: \$title, authorId: \$authorId) {
        id
        title
        author {
          id
          name
        }
      }
    }
  """;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Book"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Query(
          options: QueryOptions(document: gql(fetchAuthorsQuery)),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              return Center(
                  child: Text(
                      'Error loading authors: ${result.exception.toString()}'));
            }

            _authors =
                List<Map<String, dynamic>>.from(result.data!['authors'] ?? []);

            if (_authors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No authors available'),
                    Text('Please add authors first'),
                  ],
                ),
              );
            }

            return Mutation(
              options: MutationOptions(document: gql(addBookMutation)),
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
                                'Book Information',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: "Book Title",
                                  prefixIcon: Icon(Icons.book),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a book title';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedAuthorId,
                                decoration: const InputDecoration(
                                  labelText: "Select Author",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                items: _authors.map((author) {
                                  return DropdownMenuItem<String>(
                                    value: author['id'],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          author['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedAuthorId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an author';
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
                                    'title': _titleController.text,
                                    'authorId': _selectedAuthorId,
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
                            : const Text("Add Book"),
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
                                    'Book "${mutationResult!.data!['addBook']['title']}" added successfully!',
                                    style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      _titleController.clear();
                                      setState(() {
                                        _selectedAuthorId = null;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(),
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
