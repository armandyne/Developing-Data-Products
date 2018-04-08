library(shiny)
library(leaflet)
library(plotly)

shinyUI(
     navbarPage("The Washington Post's Police Shootings",
                tabPanel("Statistics",
                         sidebarPanel(
                              sliderInput("years", 
                                          "Years:", 
                                          min = min(ds$Year), 
                                          max = max(ds$Year),
                                          value = range(ds$Year),
                                          sep = "",
                                          step = 1
                                          ),
                              selectInput("selRace",
                                          "Race:",
                                          choices = c("All", unique(ds$Race)),
                                          selected = "All"),
                              selectInput("selThreatLevel",
                                          "Threat level:",
                                          choices = c("All", unique(ds$ThreatLevel)),
                                          selected = "All"
                                          ),
                              wellPanel(
                                   radioButtons("rbGender",
                                                "Gender:",
                                                list("Both" = "Both", "Female" = "Female", "Male" = "Male"),
                                                selected = "Both")
                              ),
                              submitButton("Apply filters")
                         ),
                         mainPanel(
                              tabsetPanel(
                                   tabPanel("Interactive map", 
                                            icon = icon("map-marker"),
                                            leafletOutput("map", height = 550)
                                            ),
                                   tabPanel("Plots", icon = icon("bar-chart-o"),
                                            plotlyOutput("plot1"),
                                            plotlyOutput("plot2"),
                                            plotlyOutput("plot3"),
                                            plotlyOutput("plot4"),
                                            plotlyOutput("plot5")
                                            ),
                                   tabPanel("Data explorer", 
                                            icon = icon("table"),
                                            dataTableOutput("datatable")
                                            )
                                   )
                              )
                         ),
                tabPanel("About App",
                         includeMarkdown("about.md")
                         )
     )
)
