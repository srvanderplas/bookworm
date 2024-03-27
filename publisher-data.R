# Scraping publishers ISBN codes
library(dplyr)
library(tidyr)
library(purrr)
library(rvest)
library(stringr)


urls <- c("https://en.wikipedia.org/wiki/List_of_group-1_ISBN_publisher_codes",
          "https://en.wikipedia.org/wiki/List_of_group-0_ISBN_publisher_codes")



pub_data <- tibble(url = urls,
                   html = purrr::map(url, read_html),
                   tables = purrr::map(html, html_table)) %>%
  unnest(tables) %>%
  mutate(pub_codes = purrr::map_lgl(tables, ~"Publisher code" %in% names(.))) %>%
  filter(pub_codes) %>%
  mutate(tables_fix = purrr::map(tables, function(x) {
    names(x) <- make.names(names(x), unique = T)
    x %>% select(which(colSums(!is.na(x))>0)) %>%
      mutate(across(everything(), as.character))
    }))


expand_code <- function(str) {
  commas <- str_split(str, " ?,", simplify = F)
  spans <- str_split(str, "[~–-]", simplify = F)
  spans <- purrr::map(spans, ~.[nchar(.) > 0])
  span_fix <- purrr::map(spans, function(x) {
    if (length(x) == 1) {
      return(as.numeric(unlist(x)))
    } else if (length(x) == 2) {
      return(seq(as.numeric(x[1]), as.numeric(x[2]), by = 1))
    } else {
      return(as.numeric(x))
    }
  })
  comma_fix <- purrr::map(commas, function(x) as.numeric(unlist(x)))
  
  if_else(str_detect(str, ","), comma_fix, span_fix)
  
}

pub_data_exp <- nest(pub_data, data_origin = c(url, html, tables, pub_codes)) %>%
  unnest(tables_fix) %>%
  filter(Publisher != "?" & !str_detect(Publisher, pattern = "see #")) %>%
  mutate(Publisher.code = str_remove_all(Publisher.code, " ?[:punct:]\\d{1,2}[:punct:]$")) 

pub_data_exp <- pub_data_exp %>%
  mutate(expand.Publisher.code = expand_code(Publisher.code)) %>%
  unnest(expand.Publisher.code) %>%
  select(Publisher.code, expand.Publisher.code, Publisher, Additional.imprints, Notes, data_origin)

x <- pub_data$tables[[3]]


publishers <- unique(pub_data_exp$Publisher) %>%
  str_remove_all("\\.mw-parser-output.*$") %>%
  str_remove_all("\\.{3}") %>%
  str_replace_all("[-;:,&–/\\[\\]]", " ") %>%
  str_squish() %>%
  str_remove_all("[\\(\\)]")
publisher_terms <- str_split(publishers, "[ ]", simplify = F) %>% unlist()
publisher_terms <- publisher_terms[nchar(publisher_terms) > 2]

search_terms <- publisher_terms %>% table() %>% sort(decreasing = T) 

publisher_searches <- crossing(tibble(search = names(search_terms), search_freq = search_terms), 
                               publisher = publishers) %>%
  arrange(desc(search_freq)) %>%
  mutate(present = str_detect(publisher, search)) %>%
  mutate(search = factor(search, levels = names(search_terms)))


tmp <- publisher_searches %>% select(-search_freq) %>% pivot_wider(names_from = search, values_from = present)
tmp2 <- as.matrix.data.frame(tmp[,-1]) 
rownames(tmp2) <- tmp$publisher
tmp <- select(tmp, -publisher) %>% as.logical()

publisher_search_terms <- c(names(tmp)[2:51], tmp$publisher[rowSums(tmp2[,1:50]) == 0])


