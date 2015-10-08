rm(list = ls())

library(foreign)
library(dplyr)


baseDirectory <- "C:/KPONEIL/SHEDS/NHDHRDV2/daymet/testing"

input <- read.csv(file.path(baseDirectory, "CSVs", "sampleDays.csv"))

input$date <- as.Date(input$date)


uniqueDates <- unique(input$date)


for ( i in seq_along(uniqueDates) ){
  
  output <- tbl_df(input) %>% 
              filter(date == uniqueDates[i])

  
  dateID <- gsub('-','', as.Date(uniqueDates[i]))
  
  write.dbf(as.data.frame(output), 
              file = file.path(baseDirectory, "DBFs",paste0("singleDay", dateID, ".dbf")))

}