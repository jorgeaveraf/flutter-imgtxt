import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../widgets/ine_widget.dart';

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
      appBar: AppBar(title: Text('INE List')),
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
}
