library(tm)
library(stringdist)

CHAT_MESSAGE_DIST_METHOD <- "cosine"
CHAT_MESSAGE_DIST_THRESHOLD <- 0.3

ClassifyMessageSimply <- function(clean.message, training.table) {
    dist <-
        training.table[, ChatMessageDistance(clean.message, message)]
    classification.table <-
        training.table[dist < CHAT_MESSAGE_DIST_THRESHOLD,]
    classification.table[, distance := ChatMessageDistance(clean.message, message)]
    classification.table[order(distance)]
}

ChatMessageDistance <- function(a, b) {
    stringdist(a, b, method = CHAT_MESSAGE_DIST_METHOD)
}
