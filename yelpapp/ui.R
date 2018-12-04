#check update
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
source("server.R")


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Yelp App"),
  setBackgroundImage(src = "https://peakfitnessmeals.com/wp-content/uploads/2017/04/bigstock-Healthy-food-background-69442900.jpg"),
  
  navbarPage("Welcome!", 
    tabPanel( "Project Description",
       textOutput("project_description")
    # Sidebar with a slider input for number of bins 
    ),
    tabPanel("Widgets",
      sidebarLayout(
        sidebarPanel(
           
           textInput("cities", label = h3("Enter your desired city and state: (ex: Seattle, WA)"), value = "Seattle")
    
        ),
        
        
        # Show a plot of the generated distribution
        mainPanel(
          tabsetPanel(type = "tabs", ## 
                      tabPanel("Top 50", dataTableOutput("table")),
                      tabPanel("Prices", plotlyOutput("priceHistogram") ),
                      
                      tabPanel("Random restaurant", fluid = TRUE,
                               sidebarLayout(
                                 sidebarPanel(actionButton("action", label = "Generate random restaurant")),
                                 mainPanel(fluidRow(tableOutput("random_table")
                                 )
                                 )
                               )
                      ), 
                
                      
                      tabPanel("Restaurant types",  plotlyOutput("graph"))
          )
        )
      ))
  )
  )
) 


