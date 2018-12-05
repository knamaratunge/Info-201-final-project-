library(shiny)
library(shinyWidgets)

# Defines user-interface for a Shiny web application displaying Yelp 
# information and visualizations. 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Team Noodle Final Project"),
  setBackgroundImage(src = "https://peakfitnessmeals.com/wp-content/uploads/2017/04/bigstock-Healthy-food-background-69442900.jpg"),
  
  navbarPage("Welcome!", 
    tabPanel( "Project Description",
       includeMarkdown("project_description.md")
       
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
                      
                      tabPanel("Prices", 
                               fluidPage(textOutput("topPrice"), 
                                         plotlyOutput("priceHistogram"))),
                      
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