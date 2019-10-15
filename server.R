#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#xxx

library(shiny)
library(readxl)
library(ggplot2)
library(ggmap)
library(dplyr)
library(geosphere)


shinyServer(function(input, output) {
  
  # Create plot 1 - Michelin Restaurants by Region
  output$plot1 <- renderPlot({
    
    
    # Read input data
    data_michelin1 <- read.csv("https://shinyr.s3.amazonaws.com/Michelin_Restaurant_2019.csv", header = T)
    data_p1 <- data.frame(data_michelin1$name,
                         data_michelin1$latitude,
                         data_michelin1$longitude,
                         data_michelin1$city,
                         data_michelin1$region,
                         data_michelin1$cuisine,
                         data_michelin1$price,
                         data_michelin1$stars,
                         data_michelin1$country)
    
    # Manipulate input data
    colnames(data_p1) <- c("Name", "Latitude", "Longitude", "City", "Region", "Cuisine", "Price", "Stars", "Country")
    data_p1$Name <- as.character(data_p1$Name)
    data_p1$Country <- as.character(data_p1$Country)
    data_p1$Stars <- as.factor(data_p1$Stars)
    
    # Plot Michelin Restaurants by Region
    g <- ggplot(data_p1, aes(x = Country, fill = Stars)) + geom_bar() +
    xlab("Region") +
    ylab("Number of Michelin Restaurants") + 
    guides(fill=guide_legend(title="Number of Stars"))
    
    # Return plot1
    g
    })
  # Create plot 2 - Michelin Restaurants by Type (interactive)
  output$plot2 <- renderPlot({
    
    # Read input data
    data_michelin2 <- read.csv("https://shinyr.s3.amazonaws.com/Michelin_Restaurant_2019.csv", header = T)
    
    # Manipulate input data
    data_2 <- data.frame(data_michelin2$name,
                         data_michelin2$latitude,
                         data_michelin2$longitude,
                         data_michelin2$city,
                         data_michelin2$region,
                         data_michelin2$cuisine,
                         data_michelin2$price,
                         data_michelin2$stars,
                         data_michelin2$country)
    colnames(data_2) <- c("Name", "Latitude", "Longitude", "City", "Region", "Cuisine", "Price", "Stars", "Country")
    data_2$Stars <- as.factor(data_2$Stars)
    
    # Filter the data for different price and region types selected by user in plot 2 tab
    target1 <- c(input$typeofprice)
    target2 <- c(input$typeofregion)
    df_plot2 <- data_2[data_2$Price %in% target1 & data_2$Country %in% target2,]
    
    # Create plot for Restaurants by Type
    df_plot2 <- within(df_plot2,Cuisine<- factor(Cuisine,levels=names(sort(table(Cuisine), dereasing=F))))
    
    p <- ggplot(df_plot2, aes(x = Cuisine, fill = Stars)) + geom_bar() +
      coord_flip() + 
      ylab('Number of Michelin Restaurants') +
      xlab('')
    
    # Return plot 2
    p
  })
  
  # Create data table output
  output$table <- renderTable({
    
    
    # Read input data
    data_michelin3 <- read.csv("https://shinyr.s3.amazonaws.com/Michelin_Restaurant_2019.csv", header = T)
    data_3 <- data.frame(data_michelin3$name,
                         data_michelin3$latitude,
                         data_michelin3$longitude,
                         data_michelin3$city,
                         data_michelin3$region,
                         data_michelin3$cuisine,
                         data_michelin3$price,
                         data_michelin3$stars,
                         data_michelin3$country)
    
    # Manipulate data
    colnames(data_3) <- c("Name", "Latitude", "Longitude", "City", "Region", "Cuisine", "Price", "Stars", "Country")
    
    # Show entire table when no cuisine is selected by user 
    if(is.null(input$typeofcuisine1)){return(data_3)}
    
    # Filter the data for different type of cuisine selected by user input
    data_t1 <- data_3[data_3$Cuisine %in% input$typeofcuisine1,]
    data_t1 <- data_t1 %>% select(Name, City, Region, Cuisine, Price, Stars)%>% arrange(Price)
    
    # Return table
    return(data_t1)})
  
  # Create map with leaflet
  output$map <- renderLeaflet({
    
    # Read input data
    data_michelin4 <- read.csv("https://shinyr.s3.amazonaws.com/Michelin_Restaurant_2019.csv", header = T)
    data_4 <- data.frame(data_michelin4$name,
                         data_michelin4$latitude,
                         data_michelin4$longitude,
                         data_michelin4$city,
                         data_michelin4$region,
                         data_michelin4$cuisine,
                         data_michelin4$price,
                         data_michelin4$stars,
                         data_michelin4$country)
    
    # Manipulate data
    colnames(data_4) <- c("Name", "Latitude", "Longitude", "City", "Region", "Cuisine", "Price", "Stars", "Country")
    
    # Filter input file for stars and types of cuisine selected by user in map tab
    target11 <- c(input$stars)
    target22 <- c(input$typeofcuisine)
    data <- data_4[data_4$Stars %in% target11 & data_4$Cuisine %in% target22,]
    
    # Create a color icon for use in legend to be displayed on map
     data$Price <- factor(data$Price)
     new <- c("pink","orange","green","blue","red")[data$Price]
     
     icons <- awesomeIcons(
      icon = "ios-close",
      iconColor = "snow",
      markerColor = new,
      library = "ion"
    )
    
    
    # Create label vector to be displayed in markers
    data$pricelabel <- paste("Restaurant Name:", data$Name, "/City:", data$City, "/Type:", data$Cuisine, "/Stars:", data$Stars, "/Price:", data$Price)
    
    
    # Create map
    leaflet(data) %>% 
      
      # Add map tiles for selected map from CartoDB.Positron.
      addProviderTiles("CartoDB.Positron") %>% 
      
      # Add coordinates for default view when application starts
      setView(lng = -97, lat = 40, zoom = 4) %>%
      
      # Add map markers
      addAwesomeMarkers(lng = ~Longitude, lat = ~Latitude, 
                        popup = ~pricelabel,
                        icon = icons
                        )%>%
      
    # Add legends for different types of price
    addLegend(
    "bottomright",
    colors = c("hotpink","darkorange","limegreen","dodgerblue","orangered"),
    labels=c("$", "$$", "$$$", "$$$$", "$$$$$"),
    opacity=1,
    title="Type of Price")
  })
  
  # Create plot user - Allow user to enter his/her location and find the nearby Michelin restaurants
  output$tableuser <- renderTable({
    
    # Read input data
    data_michelin5 <- read.csv("https://shinyr.s3.amazonaws.com/Michelin_Restaurant_2019.csv", header = T)
    data_5 <- data.frame(data_michelin5$name,
                         data_michelin5$latitude,
                         data_michelin5$longitude,
                         data_michelin5$city,
                         data_michelin5$region,
                         data_michelin5$cuisine,
                         data_michelin5$price,
                         data_michelin5$stars,
                         data_michelin5$country)
    
    # Manipulate data
    colnames(data_5) <- c("Name", "Latitude", "Longitude", "City", "Region", "Cuisine", "Price", "Stars", "Country")
    data_5$Distance <- "NA"
    
    # Calculate user distance between restaurants
    user_lat <- as.numeric(input$lat)
    user_long <- as.numeric(input$long)
    for (i in 1:length(data_5$Name)){
      a <- as.numeric(data_5[i,3])
      b <- as.numeric(data_5[i,2])
      d1 <- distHaversine (c(data_5$Longitude[i],data_5$Latitude[i]), c(user_long, user_lat)) # meters
      d11 <- d1*0.0006213712
      data_5$Distance[i] <- paste(round(d11, digit = 2), "miles")
    }
    # Filter the data for different location selected by user input
    data_t5 <- data_5[data_5$City %in% input$location,]
    
    # Arrange distance from the nearst to the farthest
    data_5_f <- data_t5 %>% filter(Distance != "NA") %>% select(Name, Latitude, Longitude, City, Cuisine, Price, Stars, Distance)%>% arrange(Distance)
    
    # Return table
    return(data_5_f)
  })
  
})