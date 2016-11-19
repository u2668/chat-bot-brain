library(data.table)
library(tm)
library(RWeka)

source("url-decode.R", encoding = "UTF-8")
source("chat-message-cleaner.R", encoding = "UTF-8")
source("chat-message-classification.R", encoding = "UTF-8")
source("chat-message-simple-classification.R", encoding = "UTF-8")
source("chat-message-matrix-factory.R", encoding = "UTF-8")
source("chat-message-time-extractor.R", encoding = "UTF-8")
source("bootstrap-training-set.R", encoding = "UTF-8")

CHAT_MESSAGE_CLASSES <- list(
    UNKNOWN = "UNKNOWN",
    CRAP = "CRAP",
    DRIVER = "DRIVER",
    PASSENGER = "PASSENGER",
    PLACE = "PLACE",
    TIME = "TIME"
)

UNKNOWN_RESULT <- list(message.class = CHAT_MESSAGE_CLASSES$UNKNOWN,
                       message.class.probability = 0)

GetChatMessageClasses <- function() {
    bot.state$training.set
}

GetChatMessageClassById <- function(id) {
    id <- URLDecode(id)
    bot.state$training.set[message.class == id]
}

ClassifyMessage <- function(message) {
    message <- URLDecode(message)
    
    message.corpus <- CleanChatMessages(message)
    known.terms.level <-
        GetKnownTermsLevel(message.corpus, Terms(bot.state$training.matrix))
    classification.table <-
        ClassifyMessageSimply(message.corpus[[1]]$content,
                              bot.state$training.table)
    if (nrow(classification.table) > 0) {
        message.class <- classification.table[[1, "message.class"]]
        message.class.probability <-
            1 - classification.table[[1, "distance"]]
        if (message.class == CHAT_MESSAGE_CLASSES$TIME) {
            message.class.meta <- ExtractTimeFromChatMessage(message)
        } else {
            message.class.meta <- classification.table[[1, "meta"]]
        }
        list(
            message.class = message.class,
            message.class.probability = message.class.probability,
            message.class.meta = message.class.meta,
            known.terms.level = known.terms.level
        )
    } else {
        UNKNOWN_RESULT
    }
}

TrainModelByMessage <- function(message.class, message, meta) {
    message.class <- URLDecode(message.class)
    message <- URLDecode(message)
    meta <- URLDecode(meta)
    
    if (is.null(CHAT_MESSAGE_CLASSES[[message.class]])) {
        return(list(error = "Unknown message class specified."))
    }
    
    if (message.class == CHAT_MESSAGE_CLASSES$UNKNOWN) {
        return(list(error = "Class UNKNOWN is reserved."))
    }
    
    message.words <- WordTokenizer(message)
    if (length(message.words) == 0) {
        return(list(error = "Empty message specified."))
    }
    
    bot.state <<-
        AppendTrainingSetToChatBotState(bot.state,
                                        data.table(message = message,
                                                   message.class = message.class,
                                                   meta = meta))
    list(
        message.class = message.class,
        message.class.probability = 1,
        known.terms.level = 1,
        meta = meta
    )
}

# START State

InitChatBotState <- function() {
    training.corpus <- VCorpus(VectorSource(character()),
                               readerControl = list(language = "ru"))
    list(
        training.set = data.table(),
        training.corpus = training.corpus,
        training.table = data.table(),
        training.matrix = DocumentTermMatrix(training.corpus),
        training.model = NULL
    )
}

AppendTrainingSetToChatBotState <-
    function(old.state, new.training.set) {
        training.set <- rbind(old.state$training.set, new.training.set)
        new.training.corpus <-
            CleanChatMessages(new.training.set[["message"]])
        training.corpus <-
            c(old.state$training.corpus, new.training.corpus)
        new.training.table <- CorpusToDataTable(new.training.corpus)
        new.training.table[, message.class := new.training.set[["message.class"]]]
        new.training.table[, meta := new.training.set[["meta"]]]
        training.table <-
            rbind(old.state$training.table, new.training.table)
        training.matrix <-
            c(old.state$training.matrix,
              CreateChatMessagesMatrix(new.training.corpus))
        training.model <-
            TrainModel(training.matrix, training.set[["message.class"]])
        list(
            training.set = training.set,
            training.corpus = training.corpus,
            training.table = training.table,
            training.matrix = training.matrix,
            training.model = training.model
        )
    }

CorpusToDataTable <- function(training.corpus) {
    data.table(message = sapply(training.corpus, as.character))
}

bot.state <- AppendTrainingSetToChatBotState(
    InitChatBotState(),
    fread(
        "data/training-set.csv",
        header = T,
        encoding = "UTF-8",
        colClasses = c("character", "factor", "factor")
    )
)

# END State