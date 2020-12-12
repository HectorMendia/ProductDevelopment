library(shiny)
library(leaflet)
library(dplyr)
library(leaflet.extras)
require(shinydashboard)
library(ggplot2)
theme_set(theme_bw())
library(DT)
library(lubridate)
library(htmltools)
library(DBI)

header <- dashboardHeader(title = "COVID-19")

sidebar <- dashboardSidebar(sidebarMenu(
    menuItem(
        "Dashboard",
        tabName = "dashboard",
        icon = icon("dashboard")
    ),
    uiOutput("output_range_date"),
    uiOutput("output_select_country")
    
    
))

frow1 <- fluidRow(
    valueBoxOutput("output_total"),
    valueBoxOutput("output_death"),
    valueBoxOutput("output_recovered"),
    
    box(
        title = "Mapa de confirmados",
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        width = 12,
        leafletOutput(outputId = "covid_confirmed_map")
    ),
    
    box(
        title = "Mapa de muertes",
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        leafletOutput(outputId = "covid_death_map")
    ),
    
    box(
        title = "Mapa de recuperados",
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        leafletOutput(outputId = "covid_recovered_map")
    ),
    box(
        title = "Tendencia de casos confirmados",
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        plotOutput("render_plot_daily")
    ),
    box(
        title = "Detalle de recuperados",
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        DT::dataTableOutput("render_data_table")
    )
)

body <- dashboardBody(frow1)

ui <-
    dashboardPage(title = 'Proyecto', header, sidebar, body, skin = 'green')