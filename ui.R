#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

shinyUI(navbarPage("Michelin Guide 2019",
                 # Create About panel
                 tabPanel("About", 
                          fluidRow(
                   column(10,
                          h1(strong("Explore the worldwide Michelin Guide!"), align = "center")),
                   column(10, h4("Have no idea where to eat? Planning for enjoying delicacy while traveling to different countries?
                          Through this application, you can see the recommended restauraunts all over the world from Michelin Guide 2019.
                          Also, you can explore the nearby Michelin restaurants by entering your current location.
                          Start your journal to the next culinary experience around the world!")),
                   column(10,
                          h5("Data Resource:"),
                          h6("This application uses database from kaggle(https://www.kaggle.com/jackywang529/michelin-restaurants).
                          The data contains restaurant infomation in the following regions: Austria, California, Chicago, Croatia, Czech Republic, Denmark, 
                          Finland, Greece, Hong Kong, Hungary, Iceland, Macau, Norway, New York City, Poland, Ireland, Rio de Janeiro, Sao Paulo, South Korea, Singapore, Sweden, Taipei, Thailand, Washington DC, and United Kingdom.")
                          ),
                   column(10,
                          img(class="img-polaroid",
                              src=paste0("https://gastronomos.fr/wp-content/uploads/2019/01/guia-michelin-2019-fran%C3%A7a-uma-chuva-de-novas-estrelas.jpg")),
                          tags$small(
                            "Source: ",
                            a(href="https://gastronomos.fr/en/restaurants/france/michelin-guide-2019-france-new-stars/",
                              "User:gastronomos")
                   )))),
                 # Create Interactive Map with leaflet output and different filters
                   tabPanel("Interactive Map", leafletOutput("map"), hr(), fluidRow(
                     column(4, offset = 1,
                            checkboxGroupInput("stars",
                                               "Stars of restaurants",
                                               c(1,2,3),
                                               selected = c(1,3))
                     ),
                     column(4,
                            checkboxGroupInput("typeofcuisine", "Type of restaurants",
                                               c("American","Chinese",
                                                 "Cantonese", "Taiwanese", 
                                                 "Japanese","Korean", 
                                                 "European", "French", 
                                                 "Italian", "Mediterranean", 
                                                 "Creative", "British"),
                                               selected = c("American","Chinese",
                                                            "Japanese", 
                                                            "European", "French"
                                                            ))
                  ))),
                 # Create tab panel which can allow user to enter his/her location and find the nearby Michelin restaurants
                 tabPanel("User Explore Nearby", fluidRow(
                   column(3,
                   textInput("lat", label = "Enter your latitude", 38.9),
                   textInput("long", label = "Enter your longitude", -77.06),
                   selectInput("location", "Choose your region", choices = list(
                     Western_America = c("San Francisco","South San Francisco", "Monterey", "Sacramento", "Los Angeles", "Costa Mesa", "San Diego"),
                     Eastern_America = c("Chicago", "New York", "Washington, D.C."),
                     Asia = c("Hong Kong","Macau", "Singapore", "Seoul", "Taipei", "Bangkok"),
                     Western_Europe = c("Edinburgh","Birmingham","Mayfair","Bristol","Newbury","Bloomsbury","Marylebone","Belfast","Leith","Dalry", "Chester", "Leeds"),
                     Eastern_Europe = c("Budapest","Warszawa","Rovinj","Rio de Janeiro","Lovran", "Sibenik", "Zagreb", "Praha","Kleinwalsertal","Hallwang", "Salzburg", "Wien"),
                     North_Europe = c("Copenhagen","Oslo","Galway", "Goteborg","Helsinki","Aarhus","Stockholm","Vejle", "Fredericia", "Horve", "Praesto", "Pedersker", "Trondheim", "Stavanger", "Lisdoonvarna", "City Centre"),
                     South_Europe = c("Athina")
                   ), selected = "Washington, D.C."
                   )),
                   column(10,tableOutput("tableuser"))
                 )),
                 # Create panel for dataset summary
                 navbarMenu("Summary Information",
                            # Create tab for plot 1
                            tabPanel("Plot - Michelin Restaurants by Region", plotOutput("plot1")),
                            # Create tab for plot 2, including filters
                            tabPanel("Plot - Michelin Restaurants by Type (interactive)",plotOutput("plot2"), hr(),fluidRow(
                              column(4, offset = 1,
                                     checkboxGroupInput("typeofprice",
                                                        "Type of price",
                                                        c("$","$$","$$$","$$$$","$$$$$"),
                                                        selected = c("$","$$","$$$","$$$$","$$$$$"))
                              ),
                              column(4,
                                     checkboxGroupInput("typeofregion", "Type of regions",
                                                        c("North America","South America", "Asia", "Europe"),
                                                        selected = c("North America","South America", "Asia", "Europe"))
                              )
                            )),
                            # Create tab for table, including filters
                            tabPanel("Table",fluidRow(
                              column(10,                                                                   
                                     selectInput("typeofcuisine1", "Type of restaurants", choices = list(
                                       America = c("American", "Mexican"),
                                       Asia = c("Asian","Chinese", "Taiwanese", "Cantonese", "Japanese", "Korean", "Indian", "Thai", "Shanghainese", "Sichuan", "Dim Sum", "Peranakan", "Fujian", "Hang Zhou"),
                                       Europe = c("French", "Italian", "British", "European", "Danish", "Mediterranean", "Swedish", "Finnish", "Spanish"),
                                       Others = c("Creative", "Seafood", "Steakhouse", "Street Food", "Barbecue", "Vegetarian", "Moroccan")
                                     )
                                     )
                            ),
                            hr(),
                            tableOutput("table"))
                            
))))

