context("Test cases for madlib.randomForest and its helper functions")

## ------------------------------------------------------------
## Test preparations
library(randomForest)
library(MASS)

env <- new.env(parent = globalenv())
.dbname = get('pivotalr_dbname', envir=env)
.port = get('pivotalr_port', envir=env)
cid <- db.connect(port = .port, dbname = .dbname, verbose = FALSE)

id <- seq(1,14)
outlook <- c('sunny', 'sunny', 'overcast', 'rain', 'rain', 'rain', 'overcast',
	'sunny', 'sunny', 'rain', 'sunny', 'overcast', 'overcast', 'rain')
temperature <- c(85,80,83,70,68,65,64,72,69,75,75,72,81,71)
humidity <- c(85,90,78,96,80,70,65,95,70,80,70,90,75,80)
windy <- c( 'false', 'true', 'false', 'false', 'false', 'true', 'true',
	'false', 'false', 'false', 'true', 'true', 'false', 'true')
class <- c( 'Don\'t Play', 'Don\'t Play', 'Play', 'Play', 'Play',
	'Don\'t Play', 'Play', 'Don\'t Play', 'Play', 'Play', 'Play', 'Play',
	'Play', 'Don\'t Play')

dat.r <- data.frame(id,outlook,temperature,humidity,windy,class)
dat.db <- as.db.data.frame(dat.r, conn.id=cid)

control1 <- list(maxdepth = 8, minsplit=3, minbucket=1, nbins=10)

## The tests
test_that("Test randomForest", {

		testthat::skip_on_cran()
		fit.golf <- madlib.randomForest(class ~ . -id, data = dat.db,
			importance=TRUE, ntree=20, id="id", control=control1)
		pred.db <- predict(fit.golf, newdata=dat.db)
		est.db <- lk(pred.db$estimated_class)
		est.db <- as.integer(est.db == "Play")

		fit.golf.r <- randomForest(class ~ . -id, data = dat.r, importance=T,
			id="id", ntree=20)
        pred.r <- predict(fit.golf.r, newdata=dat.r)
        est.r <- as.integer(pred.r == "Play")

        expect_equal(est.db, est.r, tolerance=1e-2, check.attributes=FALSE)

})
