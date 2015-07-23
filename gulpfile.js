var gulp = require('gulp');
var cssnext = require('gulp-cssnext');
var rev = require('gulp-rev');
var rename = require('gulp-rename');
var del = require('del');
var runSequence = require('run-sequence');
var babel = require('gulp-babel');

gulp.task('clean', function(cb) {
  del([
    './tmp',
    './public/assets',
  ], cb);
});

gulp.task('css', function() {
  return gulp
    .src('./app/css/**/*.css')
    .pipe(cssnext({compress: true}))
    .pipe(gulp.dest('./tmp/assets'));
});

gulp.task('js', function() {
  return gulp
    .src('./app/js/**/*.js')
    .pipe(babel())
    .pipe(gulp.dest('./tmp/assets'));
});

gulp.task('clean-and-compile-assets', function(cb) {
   runSequence(
    'clean',
    ['css', 'js'],
    cb
  );
});

gulp.task('assets', ['clean-and-compile-assets'], function() {
  return gulp
    .src(['./tmp/assets/**/*.css', './tmp/assets/**/*.js'])
    .pipe(rev())
    .pipe(gulp.dest('./public/assets'))
    .pipe(rev.manifest())
    .pipe(rename('assets-manifest.json'))
    .pipe(gulp.dest('./'));
});


gulp.task('watch', ['assets'], function() {
  gulp.watch(['./app/css/**/*.css', './app/js/**/*.js'], ['assets']);
});
