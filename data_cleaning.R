pacman::p_load(data.table,dplyr,readxl, tidyr, writexl,readr,
               lubridate,xlsx,httr,stringr,jsonlite,ssh,stringdist,
               reshape2,plotly, lubridate, DT ,kableExtra,shiny,shinythemes,
               shinydashboard,shinyWidgets,knitr,rmarkdown,evaluate,base64enc,
               digest,highr,htmltools,xfun,yaml,mime)

# TABLES
fp_receipts = readRDS("data/fp_receipts.rds")
fp_map = readRDS("data/fp_map.rds")

#-----------------------------------------

#DATA CLEANING FUNCTIONS
clean_product <- function(x) {
  x <- gsub("\\?", "Ə", x)
  x <- toupper(x)
  
  x <- gsub("([0-9]+),([0-9]+)", "\\1.\\2", x)
  
  x <- gsub("(?<=\\d)\\.(?=\\d)", "DECIMALPOINT", x, perl = TRUE)
  
  x <- gsub("[[:punct:]]", " ", x)
  
  x <- gsub("DECIMALPOINT", ".", x)
  
  x <- chartr("ƏŞİÖÜÇĞ", "ESIOUCG", x)
  
  x <- gsub("\\bKG[S]*\\b", " KQ", x)
  x <- gsub("\\b(KGR|KGS)\\b", " KQ", x)
  x <- gsub("\\b(GR|G)\\b", " QR", x)
  x <- gsub("\\b(LT|LITR|LTR)\\b", " LT", x)
  x <- gsub("\\b(ML)\\b", " ML", x)
  
  x <- gsub("X([0-9]+)", "\\1 EDED", x) 
  x <- gsub("\\*([0-9]+)", "\\1 EDED", x)
  x <- gsub("([0-9]+)\\s*(PCS|ADET|ƏDƏD|ED|EDED)", "\\1 EDED", x)

  x <- gsub("\\.0\\b", "", x)
  
  x <- gsub("\\s+", " ", x)
  x <- trimws(x)
  
  return(x)
}



clean_pos <- function(x) {
  x <- gsub("\\?", "Ə", x)
  x <- toupper(x)
  x <- gsub("[[:punct:]]", " ", x)
  x <- chartr("ƏŞİÖÜÇĞ", "ESIOUCG", x)
  x <- gsub("\\s+", " ", x)
  x <- trimws(x)
  
  return(x)
}



# RECEIPTS CLEANING
fp_receipts[, product_clean := clean_product(product_name)]
fp_receipts[, pos_clean := clean_pos(pos)]
fp_receipts[, rec_date_period := as.numeric(format(as.Date(rec_date, "%m/%d/%Y"), "%Y%m"))]

# MAP CLEANING
fp_map[, product_clean := clean_product(product)]

# JOIN
setkey(fp_receipts, product_clean, rec_date_period)
setkey(fp_map, product_clean, period)
full_tab <- fp_map[fp_receipts, nomatch = 0]


# REC_ID CLEANING
full_tab[, rec_id := gsub("\\?", "Ə", rec_id)]
full_tab[, rec_id := gsub("[^A-Z0-9_]", "", rec_id)]
full_tab[, rec_id := gsub(" ", "", rec_id)]

full_tab[grepl("BRAVO", pos_clean), rec_id := sub("^[A-Z]+", "BRA", rec_id)]
full_tab[grepl("OBA", pos_clean), rec_id := sub("^[A-Z]+", "OBA", rec_id)]
full_tab[grepl("ARAZ", pos_clean), rec_id := sub("^[A-Z]+", "ARA", rec_id)]
full_tab[grepl("BAZARSTORE", pos_clean), rec_id := sub("^[A-Z]+", "BAZ", rec_id)]
full_tab[grepl("RAHAT", pos_clean), rec_id := sub("^[A-Z]+", "RAH", rec_id)]
full_tab[grepl("BIZIM", pos_clean) | grepl("BİZİM", pos_clean), rec_id := sub("^[A-Z]+", "BIZ", rec_id)]
full_tab[grepl("MEGASTORE", pos_clean), rec_id := sub("^[A-Z]+", "MEG", rec_id)]

full_tab[, rec_id := toupper(rec_id)]


full_tab[, c("product", "product_name", "pos") := NULL]
setnames(full_tab, "product_clean", "product")
setnames(full_tab, "pos_clean", "pos")



# Heftenin gunleri, Total Price, Profit
full_tab[, day_of_week := weekdays(rec_date)]
full_tab[, total_sales := qnt * unit_price]
full_tab[, profit := round(total_sales * profit_margin, 2)]
