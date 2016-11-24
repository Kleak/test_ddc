var dart = require("dart_sdk");
var entry = require("./test_ddc.dart.js");

dart._debugger.registerDevtoolsFormatter();

if (module && module.hot) {
  console.log('HOT RELOADING SETUP');
  module.hot.accept("./test_ddc.dart.js", function (err) {
    if (!err.message) {
      console.log('HOT RELOADING');
      entry = require("./test_ddc.dart.js");
      entry.web__test_ddc.main();
    } else {
      console.log('HOT RELOADING ERROR');
      console.log(err.message);
    }
  });
}
entry.web__test_ddc.main();
