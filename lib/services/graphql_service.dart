import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class GraphQLService {
  static HttpLink httpLink = HttpLink('http://localhost:8000/graphql/');

  static AuthLink? authLink;
  static Link? link;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AUTH_TOKEN);

    authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : '',
    );

    link = authLink!.concat(httpLink);

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: link!,
    );

    clientNotifier.value = client;
  }

  static late GraphQLClient client;
  static ValueNotifier<GraphQLClient> clientNotifier = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink('http://localhost:8000/graphql/'), // Dummy link
    ),
  );

  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AUTH_TOKEN, token);
    await init(); // Re-initialize the client with the new token
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AUTH_TOKEN);
    await init(); // Re-initialize the client without the token
  }
}
