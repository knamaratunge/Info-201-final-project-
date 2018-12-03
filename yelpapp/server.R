#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
## our app

library(shiny)
library(tidyr)
library(dplyr)
library(httr)
library(jsonlite)
library(maps)
library(ggplot2)
library(plotly)
library(stringr)
library(RColorBrewer)
##library(ggmap)
##register_google(key = "yourkeyhere")

yelp_key <- "WIZ9vy0AqeqYf_pxMOmBFcSLnhhF4iZmgdlSdK2E3FOM7Zb8X3naitCp58p1pZIGypOIhi1Tdv020jQGNxHsmgv7D1I1cu3h_7cZkbvDqGGN3V7QZ3mSd4cTCXf8W3Yx"
id <- "e6EqQUv9rODp67CGhfDoBg"

get_business_list <-function(city_name) {
  params <- list( term = "food", location = city_name, limit = 50)
  response <- GET("https://api.yelp.com/v3/businesses/search", 
                  add_headers('Authorization' = paste("Bearer", yelp_key)), 
                  query = params)
  content <- content(response, 'text')
  data <- fromJSON(content)
  return(data$businesses)
}

##top 5 most populated cityz
##us_citites <- us.cities
##top_cities <- arrange(us_citites, desc(pop)) %>% slice(1:5) %>% select(name) 
##cities <- unlist(top_cities)
##names(cities) <- cities


shinyServer(function(input, output) {
   
  table_data <- reactive({
    businesses <- get_business_list(input$cities) %>% flatten() %>% arrange(desc(rating)) ##makes it by highest rating
    top_ten <- head(businesses,n=10) 
    select(top_ten, name, rating, review_count, price, location.address1) 
  })
  
  output$table <- renderTable({
    table_data()
  })
  
  output$priceHistogram <- renderPlot({
    businesses <- get_business_list(input$cities)
    businesses <- businesses %>% flatten() %>% mutate(price_level = nchar(price))
    businesses_no_na <- na.omit(businesses)
    
    ggplot(businesses_no_na, aes(x=factor(price_level), fill = price_level)) + 
      geom_bar(color = "grey", width=.8) + 
      labs(x = "Price Level (Cost per person)") +
      scale_x_discrete(labels = c("Less than $10", "$11-$30", "$31-$60", "More than $60")) + 
      theme_minimal() + 
      guides(fill=FALSE)
  })
  
  random_data <- reactive({
    businesses <- get_business_list(input$cities)
    businesses <- flatten(businesses)
    ran_table <- select(businesses, name, review_count, rating, price, location.address1, display_phone)
    sample <- (sample_n(ran_table, size = 1, replace = TRUE))
    column_data <- data.frame("Info" = c(sample[1,1], sample[1,2], sample[1,3], sample[1,4], sample[1,5], sample[1,6]))
    column_category <- data.frame("Business"= c("name:", "count:", "rating:", "price:", "location:", "phone:"))
    final_data <- cbind(column_category, column_data) 
    return(final_data)  
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
  
  output$graph <- renderPlotly({
    businesses <- get_business_list(input$cities)
    categories <- select(businesses, categories)
    categories <- unnest(categories)
    summary <- group_by(categories, title) %>% 
       summarise( n=n())
    categorie_table <- arrange(summary, desc(n)) 
    top_categories <- filter(categorie_table, n > 1) 
    other_categories <- filter(categorie_table, n <= 1)
    total <- sum(top_categories$n) + nrow(other_categories)
    new_row <-data.frame("other", nrow(other_categories))
    names(new_row)<-c("title","n")
    top_categories <- rbind(top_categories, new_row)
    top_categories <- top_categories %>% mutate(percent = round((n / total) * 100, 2))
    ##colors <- c('rgb(102,194,165)', 'rgb(252,141,98)', 'rgb(141,160,203)', 'rgb(231,138,195)', 'rgb(166,216,84)', 'rgb(255,217,47)', 'rgb(229,196,148)')
    graph <- plot_ly(top_categories, labels = ~title, values = ~percent, type = "pie",
            marker = list(colors = colors,
                          line = list(color = '#FFFFFF', width = 1))) %>% 
      layout(title = "title",
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

    
    # graph <- 
    #   ggplot() +
    #       geom_bar(data = top_categories, mapping = aes(x = title, y = n , fill = n ))
    # bp <- ggplot(categories, aes(x="", y=title, fill=title))+
    #   geom_bar(width = 1, stat = "identity")
    # pie <- bp + coord_polar("x", start=0)
    return(graph)
    
  })
  
  
  
})



