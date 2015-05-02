gulp            = require "gulp"
plugins         = require("gulp-load-plugins")()
es              = require "event-stream"
mainBowerFiles  = require "main-bower-files"
childProcess    = require "child_process"
browserify      = require "browserify"
through         = require "through2"
source          = require "vinyl-source-stream"
buffer          = require "vinyl-buffer"
transform       = require "vinyl-transform"
exorcist        = require "exorcist"

gulp.task "default", [ "server", "watch" ]

gulp.task "clean", (done) ->
  childProcess.exec "rm -rf public", done

gulp.task "server", [ "build" ], (done) ->
  require "./index"
  process.on "SIGINT", ->
    done()
    process.exit()

gulp.task "build", ->
  b = browserify(debug: true).transform("coffeeify")

  gulp.src [ "src/**/*.jade" ]
    .pipe plugins.plumber()
    .pipe plugins.inject es.merge([
      gulp.src mainBowerFiles(), read: false
      gulp.src "src/**/*.coffee"
        .pipe plugins.plumber()
        .pipe through.obj (data,enc,cb) ->
          b.add data.path
          cb()
        , (cb) ->
          b.bundle (err,res) =>
            @push res unless err
            cb err
        .pipe source "index.js"
        .pipe buffer()
        .pipe gulp.dest "public"
        .pipe transform (fname) -> exorcist fname + ".map"
      gulp.src "src/**/*.sass"
        .pipe plugins.plumber()
        .pipe plugins.sourcemaps.init()
        .pipe plugins.sass indentedSyntax: true
        .pipe plugins.sourcemaps.write "."
        .pipe gulp.dest "public"
    ]), ignorePath: "public", addRootSlash: false
    .pipe plugins.jade pretty: true
    .pipe gulp.dest "public"

gulp.task "watch", ->
  plugins.watch "./src/**/*", plugins.batch (e,cb) ->
    gulp.start "build"
    cb()
