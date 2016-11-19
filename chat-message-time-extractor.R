library(stringi)

CHAT_MESSAGE_TZ <- "Europe/Moscow"

CHAT_MESSAGE_DATE_FORMATS <- list(
    "\\d+\\s*:\\s*\\d+" = "%H:%M",
    "\\d{2}" = "%H"
)

ExtractTimeFromChatMessage <- function(message) {
    result <- Filter(Negate(is.na), Map(
        f = function(pattern) {
            message.time.text <- stri_extract_first_regex(message, pattern)
            date.format <- CHAT_MESSAGE_DATE_FORMATS[[pattern]]
            time <- strptime(message.time.text,
                             format = date.format,
                             tz = CHAT_MESSAGE_TZ)
            as.numeric(time)
        },
        names(CHAT_MESSAGE_DATE_FORMATS)
    ))
    as.numeric(result)
}