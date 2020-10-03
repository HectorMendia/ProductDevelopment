#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    contador <- reactiveValues(cont1 = 0, cont2 = 0)
    
    output$input1 <- renderText(paste0(c('Output slider input: ', input$input1), collapse = ''))
    output$input2 <- renderText(input$input2)
    output$input3 <- renderText(input$input3)
    output$input4 <- renderText({
        listaValores <- paste0(input$input4, collapse = ', ')
        paste0(c("Selecciones del UI: ", listaValores), collapse = "")
    })
    output$input5 <- renderText(as.character(input$input5))
    output$input6 <- renderText(as.character(input$input6))
    output$input7 <- renderText(input$input7)

    output$input8 <- renderText(input$input8)
    output$input9 <- renderText(input$input9)
    output$input10 <- renderText(input$input10)
    output$input11 <- renderText(input$input11)
    output$input12 <- renderText(input$input12)
    output$input13 <- renderText(input$input13)

    observeEvent(input$btn1, {
        contador$cont1 <- contador$cont1 + 1
    })
    output$btn1 <- renderText(contador$cont1)
    
    observeEvent(input$btn2, {
        contador$cont2 <- contador$cont2 + 1
    })
    output$btn2 <- renderText(contador$cont2)
    
})
