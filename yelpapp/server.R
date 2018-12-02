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
library(plyr)


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
  details <- data.frame(unlist(data))
  ##names(details) = c("id")
  
}



getCityData <- reactive({
  
  
})
##top 5 most populated cityz
##us_citites <- us.cities
##top_cities <- arrange(us_citites, desc(pop)) %>% slice(1:5) %>% select(name) 
##cities <- unlist(top_cities)
##names(cities) <- cities




# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  
  table_data <- reactive({
    if(is.null(input$cities)) {
      return(get_business_list("Seattle, WA"))
    }
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
    top_ten <- flatten(top_ten)
    
    states <- map_data("state")
    ggplot() + 
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
    ##details <- flatten(details
    ran_table <- select(businesses, name, review_count, rating, image_url)
    sample <- (sample_n(ran_table, size = 1, replace = TRUE))
    flip <- data.frame("Business info" = c(sample[1,1], sample[1,2], sample[1,3], sample[1,4]))
    return(flip)

  })
  
  output$random_table <- renderTable({
    random_data()
  })
  
  output$picture <- renderText({
    ran <- random_data()
      c(
        '<img src="',ran[4,1] ,
        '">'
        
      )
  })
  
  output$graph <- renderPlot({
    
    businesses <- get_business_list(input$cities)
    categories <- businesses$categories
    categories <- ldply(categories, data.frame)
    
    ggplot() +
          geom_bar(data = c, mapping = aes(x = title, y = , fill = title )) 
    
  })
  
  
})

