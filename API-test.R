library(httr)
library(xml2)
library(rvest)
library(glue)
library(tibble)
library(dplyr)
library(purrr)

headers = c(
  'accept' = 'application/json',
  'Authorization' = Sys.getenv("ISBNDB_KEY"),
  'Content-Type' = 'application/json'
)

url <- "https://api2.isbndb.com/books/{query}?page={page}&pageSize=1000&column={columnName}"


url <- glue("https://api2.isbndb.com/books/science%20fiction?page={i}&pageSize=1000&column=subjects", i = 1:10)

resp <- tibble(url = url, resp = purrr::map(url, ~GET(., add_headers(headers))))

resp <- resp %>% mutate(df = map(resp, ~jsonlite::parse_json(content(., as = "text"), simplifyVector=T)))

df = jsonlite::parse_json(content(resp, as = "text"), simplifyVector = T)
