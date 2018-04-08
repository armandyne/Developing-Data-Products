library(shiny)
library(leaflet)
library(dplyr)
library(stringr)
library(plotly)
library(rgdal)

shinyServer(function(input, output) {
     
     filtered_ds <- reactive({
          ds %>% 
               filter(Year >= input$years[1] & Year <= input$years[2]) %>% 
               filter(input$selRace == "All" | Race == input$selRace) %>% 
               filter(input$selThreatLevel == "All" | ThreatLevel == input$selThreatLevel) %>%
               filter(input$rbGender == "Both" | Gender == input$rbGender)
     })
     
     agg_filtered_ds <- reactive({
          filtered_ds() %>%
               count(State)
     })
     
     output$datatable <- renderDataTable({filtered_ds()})
     
     output$plot1 <- renderPlotly({
          plot_ly(x = filtered_ds()$Age, type = "histogram", name = "Histogram") %>% 
               add_trace(x = density(filtered_ds()$Age)$x, 
                         y = density(filtered_ds()$Age)$y, 
                         type = "scatter", 
                         mode = "lines", 
                         fill = "tozeroy", 
                         yaxis = "y2", 
                         name = "Density") %>% 
               layout(title = "Age density",
                      yaxis2 = list(overlaying = "y", side = "right"))          
     })

     output$plot2 <- renderPlotly({
          plot_ly(data = filtered_ds(), x = ~Year, color = ~MannerOfDeath) %>% 
               add_histogram() %>% 
               layout(title = "Manner Of Death")
     })
     
     output$plot3 <- renderPlotly({
          plot_ly(data = filtered_ds(), x = ~Year, color = ~Armed) %>% 
               add_histogram() %>% 
               layout(title = "Armed", yaxis = list(type = "log"))
     })
     
     output$plot4 <- renderPlotly({
          plot_ly(data = filtered_ds(), x = ~Year, color = ~Flee) %>% 
               add_histogram() %>% 
               layout(title = "Flee")
     })
     
     output$plot5 <- renderPlotly({
          plot_ly(data = filtered_ds(), x = ~Year, color = ~MentalIllness) %>% 
               add_histogram() %>% 
               layout(title = "Mental Illness")
     })
     
     output$map <- renderLeaflet({
          leaflet_data  <- merge(states_map, agg_filtered_ds(), by.x = "STUSPS", by.y ="State")
          leaflet_data <- leaflet_data[!is.na(leaflet_data$n),]
          
          my_bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
          my_palette <- colorBin("viridis", domain = leaflet_data$n, bins = my_bins)
          my_labels <- sprintf("<strong>%s</strong><br>%g people were fatally shot by police",
                               leaflet_data$NAME, leaflet_data$n) %>% 
               lapply(htmltools::HTML)
          
          leaflet_markers_data <- filtered_ds() %>% 
               mutate(PopupContent = str_c(sprintf("<h3>%s, %s</h3>", City, State),
                                           sprintf("Date: %s<br>", as.character(Date)),
                                           sprintf("%s aged %s<br>", as.character(Age), Gender),
                                           sprintf("Armed with: %s<br><hr>", Armed),
                                           MannerOfDeath))
          
          leaflet(data = leaflet_data) %>%
               addTiles() %>%
               addPolygons(fillColor = ~my_palette(n), 
                           fillOpacity = 0.5, 
                           weight = 1,
                           color = "white",
                           opacity = 0.5,
                           highlight = highlightOptions(
                                weight = 3,
                                color = "#666",
                                bringToFront = TRUE,
                                dashArray = ""),
                           label = my_labels) %>% 
               addLegend(title = "Number of shooting", 
                         pal = my_palette, 
                         values = ~n, 
                         position = "bottomright") %>%
               addMarkers(data = leaflet_markers_data, 
                          lat = ~Lat, lng = ~Lng, 
                          clusterOptions = markerClusterOptions(),
                          popup = ~PopupContent) %>%
               setView(lng = -93.85, lat = 37.45, zoom = 4)

     })
})
