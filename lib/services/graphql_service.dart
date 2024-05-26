import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink _httpLink = HttpLink('http://10.0.2.2:8000/graphql/');


  static final ValueNotifier<GraphQLClient> clientNotifier =
      ValueNotifier<GraphQLClient>(
    GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(),
    ),
  );

  static GraphQLClient get client => clientNotifier.value;
}
