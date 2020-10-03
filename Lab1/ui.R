#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application 
shinyUI(
    fluidPage(
        # Application title
        titlePanel("Inputs en Shiny"),
        tabsetPanel(
        tabPanel("Input Examples",
            fluidPage(

    
            sidebarLayout(
                sidebarPanel(
                    sliderInput("input1",
                                "Seleccione valor",
                                min = 0,
                                max = 100,
                                value = 50,
                                step = 10,
                                animate = TRUE, post = '%'),
                    sliderInput("input2",
                                "Seleccione un rango",
                                min = 0,
                                max = 200,
                                value = c(0, 50),
                                step = 10),

                    selectInput('input3', 'Seleccione un auto:', rownames(mtcars),
                                'Duster 360'),
                    selectInput('input4', 'Seleccione un autos:', rownames(mtcars),
                                'Duster 360', multiple = TRUE),

                    dateInput('input5', 'Ingrese la fecha:', value = Sys.Date() - 1, format = "yyyy-mm-dd"),
                    dateRangeInput("input6", "Ingrese Fechas",
                                start = Sys.Date() - 10,
                                end = Sys.Date() + 10,
                                min = Sys.Date() - 40,
                                max = Sys.Date() + 40,
                                format = "yyyy-mm-dd",
                                separator = " to "),

                    numericInput("input7", "Ingrese un numero:", 
                        value = 10, min = 0, max = 100, step = 1),

                    checkboxInput("input8", "Seleccione si verdadero", FALSE),
                    checkboxGroupInput("input9", "Seleccione opciones", 
                        #c("A" = "a", "B" = "b", "C" = "c", "D" = "d", "E" = "e")
                        choices = LETTERS[1:5]
                        ),
                    radioButtons("input10", "Ingrese Genero", c("masculino" = "m", "femenino" = "f")),


                    textInput("input11", "Ingrese texto"),


                    textAreaInput("input12", "Ingrese parrafo"),
                    passwordInput("input13", "Password"),

                    actionButton("btn1", "ok"),
                    actionLink("btn2", "siguiente"),
                    submitButton("Reprocesar"),

            ),
                    mainPanel(
                        h2("Slider input sencillo"),
                        verbatimTextOutput("input1"),

                        h2("Slider input rango"),
                        verbatimTextOutput("input2"),

                        h2("Select input"),
                        verbatimTextOutput("input3"),

                        h2("Select Input Multiple"),
                        verbatimTextOutput("input4"),

                        h2("Fecha"),
                        verbatimTextOutput("input5"),

                        h2("Rango de fechas"),
                        verbatimTextOutput("input6"),

                        h2("Numeric Input"),
                        verbatimTextOutput("input7"),

                        h2("Single Checkbox"),
                        verbatimTextOutput("input8"),

                        h2("Grouped checkbox"),
                        verbatimTextOutput("input9"),

                        h2("Radio Buttons"),
                        verbatimTextOutput("input10"),

                        h2("Texto"),
                        verbatimTextOutput("input11"),

                        h2("Parrafo"),
                        verbatimTextOutput("input12"),
                        h2("Password"),
                        verbatimTextOutput("input13"),


                        h2("Action Button"),
                        verbatimTextOutput("btn1"),
                        h2("Action Link"),
                        verbatimTextOutput("btn2"),

                )
            ))),
    tabPanel("Cargar Archivo", "contents")

    )
))
