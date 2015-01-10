yo   = require "yeoman-generator"
path = require "path"
_    = require "lodash"

module.exports = class extends yo.generators.Base
  prompts: ->
    done = @async()
    @prompt [
      {
        type: "input"
        name: "name"
        message: "What is the project name?"
        default: process.cwd().split(path.sep).pop()
      }
    ], (values) =>
      @values = { name: values.name }
      @prompt [
        {
          type: "input"
          name: "description"
          message: "What is a brief description for the project?"
          default: @values.name + " project"
        }
        {
          type: "input"
          name: "repository"
          message: "What is the url for the project repository?"
          default: "https://github.com/jjg1914/" + @values.name
        }
      ], (values2) =>
        _.extend @values, _.pick values2, "description", "repository"
        done()

  _packageFile: ->
    name: @values.name
    version: "0.1.0"
    description: @values.description
    repository: @values.repository + ".git"
    author: "John J. Glynn IV"
    license: "MIT"
    bugs: @values.repository + "/issues"
    homepage: @values.repository
    dependencies: {
      "grunt": "~0.4"
      "jjg1914-grunt": "git://github.com/jjg1914/grunt-jjg1914.git#v0.1.0"
    }

  packageFile: ->
    @write "package.json", JSON.stringify @_packageFile(), null, 2

  _bowerFile: ->
    name: @values.name
    dependencies: {}

  bowerFile: ->
    @write "bower.json", JSON.stringify @_bowerFile(), null, 2

  _gemFile: ->
    source: "https://rubygems.org"
    dependencies: {
      compass: "~> 1.0"
    }

  gemFile: ->
    @template "_Gemfile", "Gemfile", @_gemFile()

  gruntFile: ->
    @template "_Gruntfile.coffee", "Gruntfile.coffee", @values

  reademe: ->
    @template "_README.md", "README.md", @values

  assets: ->
    @mkdir "assets"
    @mkdir "assets/html"
    @mkdir "assets/js"
    @mkdir "assets/css"
    @mkdir "assets/json"
    @template "assets/html/_index.haml", "assets/html/index.haml", @values
    @template "assets/js/_index.coffee", "assets/js/index.coffee", @values
    @template "assets/css/_index.sass", "assets/css/index.sass", @values
    @template "assets/json/_index.yaml", "assets/json/index.yaml", @values
