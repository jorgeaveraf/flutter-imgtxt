import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink _httpLink = HttpLink('http://35.247.110.26:8080/graphql/');


  static final ValueNotifier<GraphQLClient> clientNotifier =
      ValueNotifier<GraphQLClient>(
    GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(),
    ),
  );

  static GraphQLClient get client => clientNotifier.value;
}
