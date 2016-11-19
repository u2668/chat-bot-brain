BootstrapTrainingSet <- function(training.set) {
    set.seed(123)
    row <- sample(1:nrow(training.set),
                  size = 10 * nrow(training.set),
                  replace = T)
    training.set[row,]
}