yo   = require "yeoman-generator"
path = require "path"
exec = require("child_process").exec
_    = require "lodash"

module.exports = class extends yo.generators.Base
  prompts: ->
    done = @async()
    @prompt [
      {
        type: "input",
        name: "repo_name",
        message: "What is the repo name?"
        default: process.cwd().split(path.sep).pop()
      }
      {
        type: "input",
        name: "bin_name",
        message: "What is the executable name?"
        default: process.cwd().split(path.sep).pop()
      
      }
    ], (values) =>
      @values = _.pick(values, "repo_name", "bin_name")
      done()

  templates: ->
    @template "_configure.ac", "configure.ac", @values
    @template "_makefile.am", "makefile.am"
    @template "_AUTHORS", "AUTHORS"
    @template "_COPYING", "COPYING"
    @template "_NEWS", "NEWS"
    @template "_README.md", "README.md"
    @template "_gitignore", ".gitignore", @values
    @mkdir "src"
    @template "src/_makefile.am", "src/makefile.am", @values
    @template "src/_main.cpp", "src/" + @values.bin_name + ".cpp"

  autotoos: ->
    @on "end", ->
      exec "aclocal", ->
        exec "autoconf", ->
          exec "automake -a"
