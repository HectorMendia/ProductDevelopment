library(shiny)
library(DT)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output) {

    #output$plot_click_options <- renderPlot({
    #    plot(mtcars$wt, mtcars$mpg, xlab="Precio del vehiculo", ylab = "millas por galon")
    #})
    outParam <- NULL
    outParamHover <- NULL
    
    selectedP <- reactive({
        #print("--->")
        #print(outParam)
        if (!is.null(input$clk$x)){
            df<-nearPoints(mtcars,input$clk,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            outParam <<- rbind(outParam,out) %>% distinct()
            print(out)
            return(out)
        }

        if(!is.null(input$dclk$x)){
            df<-nearPoints(mtcars,input$dclk,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            outParam <<- setdiff(outParam,out)
            return(out)
        }
        
        if(!is.null(input$mhover$x)){
            df<-nearPoints(mtcars,input$mhover,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            outParamHover <<- out
            return(outParamHover)
        }
        
        if(!is.null(input$mbrush)){
            df<-brushedPoints(mtcars,input$mbrush,xvar='wt',yvar='mpg')
            out <- df %>% 
                select(wt,mpg)
            outParam <<- rbind(outParam,out) %>% 
                dplyr::distinct()
            return(out)
        }
        
    })
    mtcars_plot <- reactive({
        plot(mtcars$wt,mtcars$mpg, xlab="Precio del vehiculo", ylab = "millas por galon")
        puntos <-selectedP()
        if(!is.null(outParamHover)){
            points(outParamHover[,1],outParamHover[,2],
                   col='gray',
                   pch=16,
                   cex=4)}
        if(!is.null(outParam)){
            points(outParam[,1],outParam[,2],
                   col='green',
                   pch=16,
                   cex=2)}
    })
    
    output$plot_click_options <- renderPlot({
        
        mtcars_plot()
    })
    

    output$salida_table <- DT::renderDataTable({
        #click_table() %>% DT::datatable()
    })
    
})
