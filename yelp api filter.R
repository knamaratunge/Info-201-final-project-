library(tidyr)
library(dplyr)
library(httr)
library(jsonlite)



yelp_key <- "WIZ9vy0AqeqYf_pxMOmBFcSLnhhF4iZmgdlSdK2E3FOM7Zb8X3naitCp58p1pZIGypOIhi1Tdv020jQGNxHsmgv7D1I1cu3h_7cZkbvDqGGN3V7QZ3mSd4cTCXf8W3Yx"
id <- "e6EqQUv9rODp67CGhfDoBg"



params <- list(  location = "Seattle", limit = 50)
response <- GET("https://api.yelp.com/v3/businesses/search", 
                add_headers('Authorization' = paste("Bearer", yelp_key)), 
                query = params)
content <- content(response, 'text')
data <- fromJSON(content)

businesses <- data$businesses
