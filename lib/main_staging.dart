import 'package:async_dispatch/app/app.dart';
import 'package:async_dispatch/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
