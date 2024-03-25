library(httr)
library(xml2)
library(rvest)

headers = c(
  'accept' = 'application/json',
  'Authorization' = Sys.getenv("ISBNDB_KEY"),
  'Content-Type' = 'application/json'
)

url <- "https://api2.isbndb.com/books/{query}?page={page}&pageSize=1000&column={columnName}"


url <- "https://api2.isbndb.com/books/science%20fiction?page=1&pageSize=1000&column=subjects"

resp <- GET(url, add_headers(headers))
