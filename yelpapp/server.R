# This defines the server logic of our Shiny web application displaying Yelp 
# information and visualizations. 

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
library(DT)

## Stores the public API key for Yelp's Fusion API. 
yelp_key <- "WIZ9vy0AqeqYf_pxMOmBFcSLnhhF4iZmgdlSdK2E3FOM7Zb8X3naitCp58p1pZIGypOIhi1Tdv020jQGNxHsmgv7D1I1cu3h_7cZkbvDqGGN3V7QZ3mSd4cTCXf8W3Yx"
id <- "e6EqQUv9rODp67CGhfDoBg"

## Given the location that the user inputs, returns data
## containing business details for restaurants nearest that location.
get_business_list <-function(city_name) {
  params <- list( term = "food", location = city_name, limit = 50)
  response <- GET("https://api.yelp.com/v3/businesses/search", 
                  add_headers('Authorization' = paste("Bearer", yelp_key)), 
                  query = params)
  content <- content(response, 'text')
  data <- fromJSON(content)
  return(data$businesses)
}

shinyServer(function(input, output) {
   
  ## Given the location that the user inputs, returns restaurant details about the 50 
  ## top rated restaurants nearest that location.
  table_data <- reactive({
    top_fifty_businesses <- get_business_list(input$cities) %>% 
      flatten() %>% 
      arrange(desc(rating)) %>%  ## sorts restaurants by rating, descending
      head(businesses,n=50) %>% 
      select(name, rating, review_count, price, location.address1) 
    colnames(top_fifty_businesses) <- c("Name", "Rating", "Number of reviews", 
                                        "Price Level", "Address")
    top_fifty_businesses
  })
  
  ## Creates data table containing restaurant information.
  output$table <- renderDataTable({
    DT::datatable(table_data(), escape = FALSE)
  })
  
  ## Outputs a bar chart of restaurant price levels of the 50 top-rated
  ## restaurants in the user's inputted location.
  output$priceHistogram <- renderPlotly({
    businesses <- get_business_list(input$cities)
    businesses <- businesses %>% flatten() %>% mutate(price_level = nchar(price))
    businesses_no_na <- na.omit(businesses)
    
    histogram <- 
      ggplot(businesses_no_na, aes(x=factor(price_level), fill = price_level)) + 
      geom_bar(color = "grey", width=.8) + 
      labs(x = "Price Level (Cost per person)", title = "Restaurant Prices Near You") +
      scale_x_discrete(labels = c("Less than $10", "$11-$30", "$31-$60", "More than $60")) + 
      theme_minimal() + 
      guides(fill=FALSE)
    
    plotly_histogram <- ggplotly(histogram, tooltip = c("count"))
  })
  
  ## Returns business information for a random restaurant in the user's 
  ## chosen location.
  random_data <- reactive({
    businesses <- get_business_list(input$cities)
    businesses <- flatten(businesses)
    ran_table <- select(businesses, name, review_count, rating, price, location.address1, display_phone)
    sample <- (sample_n(ran_table, size = 1, replace = TRUE))
    column_data <- data.frame("Info" = c(sample[1,1], sample[1,2], sample[1,3], sample[1,4], sample[1,5], sample[1,6]))
    column_category <- data.frame("Business"= c("name:", "count:", "rating:", "price:", "location:", "phone:"))
    final_data <- cbind(column_category, column_data) 
    random_button()
    return(final_data)  
  }) 
  
  ## Creates a table for a random restaurant in the uesr's chosen location.
   output$random_table <- renderTable({
     random_data()
   })

  ## Outputs a pi chart of the restaurant categories for the top 50 restaurants
  ## in the the user's chosen location.
  ## Restaurant categories that match only one restaurant in the location are
  ## combined into the "Other" category for added chart clarity. 
  output$graph <- renderPlotly({
    businesses <- get_business_list(input$cities) 
    categories <- select(businesses, categories) %>% unnest()
    summary <- group_by(categories, title) %>% 
       summarise(n=n())
    categorie_table <- arrange(summary, desc(n)) 
    top_categories <- filter(categorie_table, n > 1) 
    other_categories <- filter(categorie_table, n <= 1) ## moves categories that match only 
                                                        ## restaurant into an "Other" category
    total <- sum(top_categories$n) + nrow(other_categories)
    new_row <-data.frame("other", nrow(other_categories))
    names(new_row) <- c("title","n")
    top_categories <- rbind(top_categories, new_row) %>% 
      mutate(percent = round((n / total) * 100, 2))
    
    graph <- plot_ly(top_categories, labels = ~title, values = ~percent, type = "pie",
            marker = list(colors = colors,
                          line = list(color = '#FFFFFF', width = 1))) %>% 
      layout(title = "Types of Restaurants Near You",
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
    return(graph)
  })

  ## Creates a button for the user to generate new random restaurant data.
  random_button <- eventReactive(input$action, {
    
  })
  
  ## Prints out a sentence stating the top price level based upon the
  ## location that the user selects. 
  output$topPrice <- renderText({
    subset_data <- get_business_list(input$cities) %>%
      flatten() %>% 
      mutate(price_level = nchar(price)) %>%
      na.omit()
    most_common_price_index <- subset_data %>% 
      summarise(price_level = getmode(price_level)) 
    labels = c("Less than $10", "$11-$30", "$31-$60", "More than $60")

    paste0("It looks like the most common price range in this area is: ", 
           labels[most_common_price_index$price_level], "!")
  })
  
  ## Given a column of a data frame, returns the mode value.   
  getmode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
  }
  
})