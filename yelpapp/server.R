#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyr)
library(dplyr)
library(httr)
library(jsonlite)
library(maps)
library(ggplot2)
library(ggmap)

register_google(key = "yourkeyhere")

yelp_key <- "WIZ9vy0AqeqYf_pxMOmBFcSLnhhF4iZmgdlSdK2E3FOM7Zb8X3naitCp58p1pZIGypOIhi1Tdv020jQGNxHsmgv7D1I1cu3h_7cZkbvDqGGN3V7QZ3mSd4cTCXf8W3Yx"
id <- "e6EqQUv9rODp67CGhfDoBg"

get_business_list <-function(city_name) {
  params <- list(  location = city_name, limit = 50)
  response <- GET("https://api.yelp.com/v3/businesses/search", 
                  add_headers('Authorization' = paste("Bearer", yelp_key)), 
                  query = params)
  content <- content(response, 'text')
  data <- fromJSON(content)
  return(data$businesses)
}

get_business_details <-function(id) {
  ##params <- list( id = id)
  response <- GET(paste0("https://api.yelp.com/v3/businesses/", id), 
                  add_headers('Authorization' = paste("Bearer", yelp_key))) 
                  ##query = params)
  content <- content(response, 'text')
  data <- fromJSON(content)
  details <- data.frame(matrix(unlist(data)))
  return(details)
}

##top 5 most populated cityz
##us_citites <- us.cities
##top_cities <- arrange(us_citites, desc(pop)) %>% slice(1:5) %>% select(name) 
##cities <- unlist(top_cities)
##names(cities) <- cities




# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  
  table_data <- reactive({
    businesses <- get_business_list(input$cities)
    top_ten <- head(businesses,n=10)
    top_ten <- flatten(top_ten)
    select(top_ten, name, rating, review_count, price, location.address1) 
    
  })
  
  output$table <- renderTable({
    table_data()
  })
  
  output$map <- renderPlot({
    businesses <- get_business_list(input$cities)
    top_ten <- head(businesses,n=10) 
    top_ten <- flatten(top_ten) %>% mutate(lower_state_name = tolower(state.name[match(location.state, state.abb)]))
    ##states <- map_data("state") %>% filter(lat >= min(top_ten$coordinates.latitude) - .1 & 
    ##                                       lat <= max(top_ten$coordinates.latitude) + .1 & 
    ##                                       long >= min(top_ten$coordinates.longitude) - .1 &
    ##                                       long <= max(top_ten$coordinates.longitude) +.1)

    city_and_state <- paste0(top_ten[1]$location.city, ",", top_ten[1]$location.state)
    satellite_map <- get_map(location = c(lon = mean(top_ten$coordinates.longitude), lat = mean(top_ten$coordinates.latitude)), zoom = 10,
                      maptype = "satellite", scale = 2) ##https://stackoverflow.com/questions/23130604/plot-coordinates-on-map
    ggmap(satellite_map) + 
    coord_fixed(1.3) +
    guides(fill=FALSE) +
    geom_point(data = top_ten, mapping = aes(x = coordinates.longitude, y = coordinates.latitude), 
               color = "green" , size = 1) +
    labs(x = "Longitude", y = "Latitude", title = "Business Map")
  })
  
  random_data <- reactive({
    random_num <- sample(1:50,1,replace=T)
    businesses <- get_business_list(input$cities)
    id <- businesses[random_num, 1]
    details <- get_business_details(id)
    ##details <- flatten(details)
    
  })
  
  output$random_table <- renderTable({
    random_data()
  })
  
  
  
})

