setwd("D:\\coursera\\Developing Data Products\\Course Project\\shinyapp")

if (!file.exists("./data")) {
     dir.create("./data")
}

if (!file.exists("./data/fatal-police-shootings-data.csv")) {
     url <-
          "https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv"
     download.file(url, destfile = "./data/fatal-police-shootings-data.csv")
}

list.files(
     "./data",
     all.files = TRUE,
     recursive = TRUE,
     include.dirs = TRUE
)