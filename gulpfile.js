var
    gulp = require("gulp")
    , _ = require("lodash")
    , $ = require("gulp-load-plugins")({lazy:true})
    , tasks = ["content", "popup"]

    , make_task = function (name) {
        gulp.task(name, function(){
            gulp.src("./app/"+ name +"/"+ name +".coffee")
                .pipe($.coffeeify())
                .pipe($.uglify())
                .pipe(gulp.dest("./build/"))
        })
    }

_.map(tasks, make_task)

gulp.task("watch", tasks ,function(){
    gulp.watch(["./app/**/*.coffee"], tasks)
})
