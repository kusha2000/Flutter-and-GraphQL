import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  static final HttpLink httpLink = HttpLink(
    'http://192.168.8.213:4000/',
  );

  static ValueNotifier<GraphQLClient> initializeClient() {
    final Link link = httpLink;
    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
