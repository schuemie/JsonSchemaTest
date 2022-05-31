library(dplyr)

getArgumentInfo <- function(createFunction) {
  args <- formals(createFunction)
  toChar <- function(x) {
    if (is.null(x)) {
      "NULL"
    } else if (is(x, "call")) {
      paste(capture.output(x), collapse = "")
    } else if (is(x, "character")) {
      paste("\"", x, "\"", sep = "")
    } else {
      as.character(x)
    }
  }
  args <- sapply(args, toChar)
  argInfo <- data.frame(name = names(args))
  argInfo$default <- NULL
  for (i in 1:length(args)) {
    argInfo$default[argInfo$name == names(args)[[i]]] <- args[[i]]
  }
  
  html <- capture.output(tools::Rd2HTML(utils:::.getHelpFile(help(createFunction))))
  argsStartPos <- grep("<h3>Arguments</h3>", html) + 1
  tableEndPos <- grep("</table>", html)
  argInfo$help <- ""
  if (length(argsStartPos) == 1 && length(tableEndPos) > 0) {
    argsEndPos <- min(tableEndPos[tableEndPos > argsStartPos])
    parameterHelp <- xml2::read_html(paste(html[argsStartPos:argsEndPos], collapse = "\n"))
    parameterHelp <- xml2::xml_find_all(parameterHelp, "//table//tr//td")
    parameterHelp <- xml2::xml_text(parameterHelp)
    parameterHelp <- iconv(parameterHelp, from = "UTF-8", to = "ASCII")
    
    for (i in 1:(length(parameterHelp) / 2)) {
      argInfo$help[argInfo$name == parameterHelp[i * 2 - 1]] <- gsub("\n", " ", parameterHelp[i * 2])
    }
  }
  return(argInfo)
}

reflect <- function(object, argumentInfo = NULL) {
  objectReflection <- list()
  if (is.list(object)) {
    objectReflection$type <- class(object)[1]
    if (objectReflection$type == "list") {
      objectReflection$type <- "object"
    }
    properties <- list()
    for (name in names(object)) {
      properties[[name]] <- reflect(object[[name]])
      if (!is.null(argumentInfo)) {
        info <- argumentInfo %>%
          filter(.data$name == !!name)
        # Workaround for covariate settings, where 'use' is dropped:
        if (nrow(info) == 0) {
          info <- argumentInfo %>%
            filter(.data$name == sprintf("use%s", !!name))
        }
        if (nrow(info) == 1) {
          if (info$help != "") {
            properties[[name]]$description <- gsub("(^ +)|( +$)", "", info$help)
          }
          if (info$default != "") {
            if (info$default == "c()") {
              info$default <- c()
            } else if (properties[[name]]$type == "boolean") {
              info$default <- as.logical(info$default)
            } else if (properties[[name]]$type == "number") {
              info$default <- as.numeric(info$default)
            } else if (properties[[name]]$type == "integer") {
              info$default <- as.integer(info$default)
            }
            properties[[name]]$default <- info$default
          }
        }
      }
    }
    objectReflection$properties <- properties
  } else if (is.vector(object)) {
    if (length(object) > 1) {
      objectReflection$type <- "array"
      objectReflection$items <- reflect(object[1])
    } else {
      if (is.integer(object)) {
        objectReflection$type <- "integer"
      } else if (is.numeric(object)) {
        objectReflection$type <- "number"
      } else if (is.character(object)) {
        objectReflection$type <- "string"
      } else if (is.logical(object)) {
        objectReflection$type <- "boolean"
      }
    }
  }
  return(objectReflection)
}




generateJsonSchema <- function(createFunction, instance) {
  argumentInfo <- getArgumentInfo(createFunction)
  reflection <- reflect(instance, argumentInfo)
  json <- jsonlite::toJSON(reflection, pretty = TRUE, force = TRUE, null = "null", auto_unbox = TRUE)
  return(json)
}