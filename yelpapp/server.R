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
    print(top_ten)
    states <- map_data("state") %>% filter(region == top_ten$lower_state_name)
    ##states <- filter(states, tolower(state.name[match(top_ten$location.state, state.abb)] == states$region))
    ##state.abb[match(x,state.name)]
    
    without_lim_map <- 
      ggplot() + 
      geom_polygon(data = states, aes(x = long, y = lat, fill = region, group = group), 
                   color = "white", fill = "grey") + 
      coord_fixed(1.3) +
      guides(fill=FALSE) +
      geom_point(data = top_ten, mapping = aes(x = coordinates.longitude, y = coordinates.latitude), 
                 color = "green" , size = 1) +
      labs(x = "Longitude", y = "Latitude", title = "Business Map")
      ##scale_x_continuous(limits = c(min(top_ten$coordinates.longitude), max(top_ten$coordinates.longitude))) +
     ## scale_y_continuous(limits = c(min(top_ten$coordinates.latitude), max(top_ten$coordinates.latitude)))
    
    limited_map <- 
      without_lim_map +       
      scale_x_continuous(limits = c(min(top_ten$coordinates.longitude), max(top_ten$coordinates.longitude))) +
      scale_y_continuous(limits = c(min(top_ten$coordinates.latitude), max(top_ten$coordinates.latitude)))
    limited_map
    
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

