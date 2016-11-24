import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bazel_worker/bazel_worker.dart';
// TODO(jakemac): Remove once this is a part of the testing library.
import 'package:bazel_worker/src/async_message_grouper.dart';
import 'package:bazel_worker/testing.dart';

var build = {
  // 'gen/js.js': ['package:js/js.dart'],
  // 'gen/func.js': ['package:func/func.dart'],
  // 'gen/captains_log.js': [
  //   'package:captains_log/captains_log.dart',
  //   'lib/quill.dart',
  //   'gen/js.sum',
  //   'gen/func.sum'
  // ],
  'gen/test_ddc.dart.js': [
    'web/test_ddc.dart',
  ]
};

List<String> compileCommand(String target, List<String> deps) {
  var command = ['--modules=common', '-o', target];
  deps.where((str) => str.endsWith('.sum')).forEach((str) {
    command.add('-s');
    command.add(str);
  });
  deps.where((str) => str.endsWith('.dart')).forEach((str) {
    command.add(str);
  });
  return command;
}

String depackage(String p) {
  if (p.startsWith('package:')) {
    return p.replaceFirst('package:', 'packages/');
  }
  return p;
}

registerWatch(String target, List<String> deps) async {
  var command = compileCommand(target, deps);
  deps.forEach((f) async {
    f = depackage(f);
    var file = new File(f);
    var process = await Process.start('dartdevc', ['--persistent_worker']);
    var messageGrouper = new AsyncMessageGrouper(process.stdout);
    file
        .watch(events: FileSystemEvent.MODIFY)
        .listen((e) => run(process, messageGrouper, command));
  });
}

void processBuild(Map<String, List<String>> map) {
  map.forEach(registerWatch);
}

run(Process process, AsyncMessageGrouper messageGrouper,
    List<String> command) async {
  print('dartdevc ${command.join(" ")}');
  var watch = new Stopwatch()..start();
  var request = new WorkRequest();
  request.arguments.addAll(command);
  process.stdin.add(protoToDelimitedBuffer(request));
  var response = await _readResponse(messageGrouper);
  var time = watch.elapsedMilliseconds;
  if (response.exitCode == 0) {
    print('Build succeeded in $time ms');
  }
  print(response.output);
}

Future<WorkResponse> _readResponse(MessageGrouper messageGrouper) async {
  var buffer = (await messageGrouper.next) as List<int>;
  try {
    return new WorkResponse.fromBuffer(buffer);
  } catch (_) {
    var bufferAsString =
        buffer == null ? '' : 'String: ${UTF8.decode(buffer)}\n';
    throw new Exception(
        'Failed to parse response:\nbytes: $buffer\n$bufferAsString');
  }
}

Process process;
AsyncMessageGrouper messageGrouper;

main() async {
  var result = Process.runSync('which', ['dartdevc']);
  print(result.stdout);
  processBuild(build);
}
