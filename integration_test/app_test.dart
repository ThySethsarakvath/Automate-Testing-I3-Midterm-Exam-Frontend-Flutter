import 'package:integration_test/integration_test.dart';
import 'auth_test.dart' as auth;
import 'posts_test.dart' as posts;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  auth.main();
  posts.main();
}