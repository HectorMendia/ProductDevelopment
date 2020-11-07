
library(shiny)
library(DT)

shinyUI(fluidPage(

    # Application title
    titlePanel("Tarea Shiny Plots"),

    tabsetPanel(

        tabPanel("Tarea",
                 plotOutput("plot_click_options",
                            click = "clk",
                            dblclick = "dclk",
                            hover = "mhover",
                            brush = "mbrush"),
                 DT::dataTableOutput("salida_table")
        )
    )
))
