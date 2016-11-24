# Requirement

Dart SDK >= 1.21.0-dev.2.0

# Step

1. ` pub get`
2. `npm install`
3. `make all`
4. `dart tool/watch.dart`
5. in a new terminal launch

  `./node_modules/.bin/webpack-dev-server --content-base=web --inline --watch --hot`

look at your browser.
You have a beautiful yellow background

now you can edit some dart code and see change in your browser.<br>
Example:

open `web/test_ddc.dart` and change the color of the background.
