path          = require "path"
async         = require "async"
yo            = require "yeoman-generator"
childProcess  = require "child_process"
fs            = require "fs"

module.exports = class extends yo.generators.Base
  generate: ->
    name = process.cwd().split(path.sep)
    name = name[name.length - 1]

    async.series [
      (cb) -> childProcess.exec "git init", cb
      (cb) -> childProcess.exec "touch .gitignore", cb
      (cb) -> childProcess.exec "git add .gitignore", cb
      (cb) -> childProcess.exec "git commit -m 'Initial Commit'", cb
      (cb) -> childProcess.exec "git remote add origin git@github.com:jjg1914/" + name + ".git", cb
      (cb) ->
        fs.writeFile ".gitignore", """
          /public
          /node_modules
          /bower_components
        """, cb
      (cb) =>
        @template "_gulpfile.coffee", "gulpfile.coffee"
        @template "_README.md", "README.md", name: name
        @template "_server.coffee", "index.coffee"

        @mkdir "src"
        @mkdir "bower_components"

        @template "_index.coffee", "src/index.coffee"
        @template "_index.jade", "src/index.jade"
        @template "_index.sass", "src/index.sass"

        @fs.writeJSON "package.json",
          name: name
          version: "0.0.0"
          description: "A generaged gulp app"
          main: "index.coffee"
          repository:
            type: "git"
            url: "https://github.com/jjg1914/" + name + ".git"
          author: "John J. Glynn IV"
          license: "MIT"
          dependencies: {}

        @fs.writeJSON "bower.json",
          name: name
          dependencies: {}

        @npmInstall [
          "coffee-script"
          "browserify"
          "coffeeify"
          "connect"
          "connect-livereload"
          "event-stream"
          "exorcist"
          "gulp"
          "gulp-batch"
          "gulp-inject"
          "gulp-jade"
          "gulp-load-plugins"
          "gulp-plumber"
          "gulp-sass"
          "gulp-sourcemaps"
          "gulp-watch"
          "gulp-yaml"
          "livereload"
          "main-bower-files"
          "morgan"
          "serve-static"
          "through2"
          "vinyl-buffer"
          "vinyl-source-stream"
          "vinyl-transform"
        ], save: true

        @on "end", =>
          async.series [
            (cb) -> childProcess.exec "git add -A", cb
            (cb) -> childProcess.exec "git commit -m 'gulp config'", cb
          ], @async()
        cb()
    ], @async()
