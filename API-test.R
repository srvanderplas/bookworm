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


url2 <- glue("https://api2.isbndb.com/books/romance?page={i}&pageSize=1000&column=subjects&year=2023", i = 1:10)

resp2 <- tibble(url = url2, resp = purrr::map(url, ~GET(., add_headers(headers))))

resp2 <- resp2 %>% mutate(df = map(resp, ~jsonlite::parse_json(content(., as = "text"), simplifyVector=T)))

df2 = bind_rows(resp2$df)



scifi <- GET("https://api2.isbndb.com/subject/Science%20Fiction", add_headers(headers))
content(scifi, as = "text") %>% jsonlite::parse_json(., simplifyVector = T)



url3 <- glue("https://api2.isbndb.com/publisher/{query}?page={page}&pageSize=1000", query = URLencode("Penguin House"), page = 1:10)


resp3 <- tibble(url = url3, resp = purrr::map(url, ~GET(., add_headers(headers))))

resp3 <- resp3 %>% mutate(df = map(resp, ~jsonlite::parse_json(content(., as = "text"), simplifyVector=T)))
