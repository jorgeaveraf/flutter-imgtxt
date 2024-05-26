import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../constants.dart';
import 'ine_list_page.dart';
import '../services/graphql_service.dart';

const String SIGNUP_MUTATION = """
  mutation SignupMutation(
    \$email: String!
    \$username: String!
    \$password: String!
  ) {
    createUser(
      email: \$email,
      username: \$username,
      password: \$password
    ) {
      user {
        id
        username
        email
      }
    }
  }
""";

const String LOGIN_MUTATION = """
  mutation LoginMutation(
    \$username: String!
    \$password: String!
  ) {
    tokenAuth(username: \$username, password: \$password) {
      
    }
  }
""";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _authenticate() async {
    final String mutation = _isLogin ? LOGIN_MUTATION : SIGNUP_MUTATION;

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'username': _usernameController.text,
        'password': _passwordController.text,
        if (!_isLogin) 'email': _emailController.text,
      },
    );

    final QueryResult result = await GraphQLService.client.mutate(options);

    if (result.hasException) {
      print(result.exception.toString());
      // Manejar errores
    } else if (result.data != null) {
      // Aquí puedes agregar el código para manejar la respuesta exitosa del login o registro
      // Por ejemplo, puedes navegar a la página siguiente
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IneListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (!_isLogin)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: _toggleForm,
              child: Text(_isLogin
                  ? 'Need to create an account?'
                  : 'Already have an account?'),
            ),
          ],
        ),
      ),
    );
  }
}
