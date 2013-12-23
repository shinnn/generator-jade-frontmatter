'use strict';

var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');

var JadeFmGenerator = function JadeFmGenerator(args, options, config) {
  yeoman.generators.Base.apply(this, arguments);

  this.on('end', function () {
    this.installDependencies({ skipInstall: options['skip-install'] });
  });

  this.pkg = JSON.parse(this.readFileAsString(path.join(__dirname, '../package.json')));
};

module.exports = JadeFmGenerator;

util.inherits(JadeFmGenerator, yeoman.generators.Base);

var GeneratorProto = JadeFmGenerator.prototype;

GeneratorProto.askFor = function askFor() {
  var cb = this.async();

  // have Yeoman greet the user.
  console.log(this.yeoman);

  var prompts = [{
    type: 'confirm',
    name: 'someOption',
    message: 'Would you like to enable this option?',
    default: true
  }];

  this.prompt(prompts, function (props) {
    this.someOption = props.someOption;

    cb();
  }.bind(this));
};

GeneratorProto.app = function app() {
  this.copy('package.json', 'package.json');
  this.copy('_bower.json', 'bower.json');
  this.copy('settings.yaml', 'settings.yaml');
};

GeneratorProto.grunt = function grunt() {
  this.copy('Gruntfile.coffee', 'Gruntfile.coffee');
};

GeneratorProto.assets = function assets() {
  this.directory('public', '');
  this.directory('img', '');
  this.directory('jade', '');
  this.directory('js', '');
  this.directory('scss', '');
	this.mkdir('img');
	this.mkdir('public/fonts');
};

GeneratorProto.projectfiles = function projectfiles() {
  this.copy('gitignore.txt', '.gitignore');
  this.copy('editorconfig', '.editorconfig');
  this.copy('jshintrc', '.jshintrc');
  this.copy('README.md', 'README.md');
};
