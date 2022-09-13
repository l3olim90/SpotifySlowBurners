library(magrittr)
library(stringi)
library(hmod)
library(here)
library(lubridate)
library(data.table)

dir = here()
setwd(dir)

# get raw
setwd("./raw")
files = list.files()

# read in files
final = NULL

for(f in files){
  
  # read in
  tmp = fread(f)[-1,]
  
  # col names
  names(tmp) = as.vector(t(tmp[1, ])) %>% tolower()
  
  # remove col name
  tmp = tmp[-1, ]
  

  # add date
  date = substr(f, 23, 32)
  
  tmp$date = date
  
  final = rbind(final, tmp)
 
  print(f)
  
}

# clean data

# make song id
artist = tolower(final$artist)
song = tolower(final$`track name`)
artist = stri_replace(" ", "_", artist)
song = stri_replace(" ", "_", song)

final$`track_lower` = paste(song, artist, sep="_") 

url_str = final$`url`
url_str = substr(url_str, 32, 53)

final$track_id = paste("spotify:track:", url_str, sep="")

# remove christmas albums
id = grep("christmas", final$`track_lower`)
final = final[-id]

id = grep("santa", final$`track_lower`)
final = final[-id]

id = grep("snow", final$`track_lower`)
final = final[-id]

id = grep("rudolph", final$`track_lower`)
final = final[-id]

names(final)[names(final) == "track name"] <- "track"
final = subset(final, select = -c(url, track_lower))

# export
setwd(dir)
setwd("./final")
fwrite(final, "daily-streams-top200.csv")


