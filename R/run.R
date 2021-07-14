


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' process a data statement
#'
#' @param code single character string representing data statement
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
process_data_statement <- function(code) {
  stopifnot(startsWith(code, "data"))

  var <- str_capture("data mytable; set 'mtcars'; run;", "data {varname}; set (?:'|\"){dataname}(?:'|\"); run;")

  if (anyNA(var)) {
    stop("DATA statement not understood: ", code)
  }

  if (exists(var$dataname)) {
    assign(var$varname, get(var$dataname), envir = .GlobalEnv)
  }

  invisible()
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' process a proc sql statement
#'
#' @param code single character string representing proc sql statement
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
process_proc_sql_statement <- function(code) {
  stopifnot(startsWith(code, "proc sql;"))

  sql <- str_capture(code, "proc sql; {sql} quit;")
  if (is.na(sql$sql)) {
    stop("PROC SQL statement not understood: ", code)
  }

  print(sqldf::sqldf(sql$sql))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Process a statement
#'
#' @param code single character string
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
process_statement <- function(code) {
  stopifnot(length(code) == 1)

  if (startsWith(code, 'proc sql;')) {
    process_proc_sql_statement(code)
  } else if (startsWith(code, 'data')) {
    process_data_statement(code)
  } else {
    stop("Unknown statement: ", code)
  }
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Process a bunch of DATA and PROC SQL statements
#'
#' @param code_vec vector of character string representing code
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
process_statements <- function(code_vec) {
  lapply(code_vec, process_statement)
  invisible((NULL))
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' split code into data and proc statements
#'
#' @param code string containing code
#'
#' @return character vector of statements
#'
#' @import stringr
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
split_into_statements <- function(code) {

  code <- tolower(code)

  bits <- stringr::str_split(code, "\n")[[1]]
  bits <- stringr::str_trim(bits)
  bits <- bits[bits != '']

  stops <- c(0L, which(bits %in% c('run;', 'quit;')))

  # Ensure that there's always a stopword at the end of the script
  if (!length(bits) %in% stops) {
    stops <- c(stops, length(bits))
  }

  statements <- c()
  for (i in seq(length(stops) - 1)) {
    statement  <- bits[(stops[i]+1):stops[i+1]]
    statement  <- paste(statement, collapse = " ")
    statement  <- stringr::str_trim(statement)
    statement  <- stringr::str_replace_all(statement, "\\s+", " ")
    statements <- c(statements, statement)
  }

  statements

}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Run code
#'
#' @param code character string containing DATA and PROC SQL statements
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
run <- function(code) {
  statements <- split_into_statements(code)
  process_statements(statements)
}




if (FALSE) {

  code <- "
data mytable;
  set 'mtcars';
run;


proc sql;
SELECT cyl, sum(mpg) as TOTSALES  FROM mytable
WHERE am = 1
GROUP BY cyl
ORDER BY cyl;
quit;"

  run(code)

}
