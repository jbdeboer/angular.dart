var fs = require('fs');
var sys = require('sys');
var exec = require('child_process').exec;

var generateParser = function(logger) {
  var log = logger.create('generate-parser');
  log.info('hello');
  return function(content, file, done) {
    log.info('Generating parser for parser test: %s', file.originalPath);

    fs.readFile(file.originalPath, function(err, data) {
      if (err) throw err;

      exec('dart tools/parser_generator/bin/parser_generator.dart', function(err, stdout, stderr) {
        if (err) throw err;
        done(data + '\n\n' + stdout);
      });
    });
  }
}

module.exports = generateParser;
