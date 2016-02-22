const gulp = require('gulp');
const elm = require('gulp-elm');
const rename = require('gulp-rename');

gulp.task('elm-init', elm.init);

gulp.task('elm', ['elm-init'], function () {
  return gulp.src('./Main.elm')
  .pipe(elm())
  .on('error', swallowError)
  .pipe(rename('main.js'))
  .pipe(gulp.dest('./'))
});

function swallowError (error) {
  console.log(error.toString());
  this.emit('end');
}

gulp.task('default', ['elm'], function () {
  gulp.watch('./*.elm', ['elm']);
});
