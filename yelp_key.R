library("jsonlite")
library("httr")
library(knitr)
library("dplyr")
library("tidyr")



yelp_key <- "WIZ9vy0AqeqYf_pxMOmBFcSLnhhF4iZmgdlSdK2E3FOM7Zb8X3naitCp58p1pZIGypOIhi1Tdv020jQGNxHsmgv7D1I1cu3h_7cZkbvDqGGN3V7QZ3mSd4cTCXf8W3Yx"
id <- "e6EqQUv9rODp67CGhfDoBg"

yelp_base_uri <-  "https://api.yelp.com/v3/" 

##hard coded NYC for testing
yelp_params <- list(key = yelp_key, address = "NYC")
yelp_uri <- paste0(yelp_base_uri, "businesses/search")
yelp_response1 <- GET(yelp_uri, query = yelp_params)
yelp_body1 <- content(yelp_response1, "text")
yelp_results1 <- fromJSON(yelp_body1)
