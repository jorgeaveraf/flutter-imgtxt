import 'package:flutter/material.dart';
import 'package:flutter_graphql/pages/login_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../widgets/ine_widget.dart';
import 'create_ine_page.dart';

const String INES_QUERY = """
  {
    ines {
      id
      nombre
      calle
      colonia
      codigoPostal
      ciudad
      estado
      fechaNacimiento
      sexo
      url
    }
  }
""";

class IneListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INE List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navegar a la página CreateInePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateInePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Implementar la funcionalidad de logout y navegación a la página de inicio
              _logout(context);
            },
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(document: gql(INES_QUERY)),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          final List ines = result.data?['ines'];

          return ListView.builder(
            itemCount: ines.length,
            itemBuilder: (context, index) {
              final ine = ines[index];
              return IneWidget(ine: ine);
            },
          );
        },
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
