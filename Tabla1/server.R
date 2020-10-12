
library(shiny)
library(DT)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output) {
    #output$contenido
    archivo_carga_1 <- reactive({
        #print('11')
        if (is.null(input$upload_file_1)){
            #print('no hay')
            return (NULL)
        }
        #print('continua')
        #browser()
        extension <- strsplit(input$upload_file_1$name, split = '[.]' )[[1]][2]
        print(extension)
        #if(input$upload_file_1$type == 'text/csv'){
        if(extension == 'csv'  | extension == 'tsv'){
            #print('correcto')
            file_data <- readr::read_csv(input$upload_file_1$datapath)
            return (file_data)
        }
        
        return (NULL)
    })

    output$contenido_archivo_1 <- renderTable({
      print('por mostrar')
      archivo_carga_1() 
    })
    
    
    
    archivo_carga_2 <- reactive({
      if (is.null(input$upload_file_2)){
        return (NULL)
      }
      extension <- strsplit(input$upload_file_2$name, split = '[.]' )[[1]][2]
      if(extension == 'csv' | extension == 'tsv'){
        file_data <- readr::read_csv(input$upload_file_2$datapath)
        return (file_data)
      }
      
      return (NULL)
    })
    
    output$contenido_archivo_2 <- DT::renderDataTable({
      #print('por mostrar')
      #DT::datatable(archivo_carga_2())
      archivo_carga_2() %>% DT::datatable(filter = 'bottom') # filter = 'top'
    })
    
    output$tabla1 <- DT::renderDataTable({
      diamonds %>%
        datatable() %>%
        formatCurrency('price') %>%
        formatString(c("x","y","z"), suffix=" mm")
    })

    output$tabla2 <- DT::renderDataTable({
      mtcars %>% DT::datatable(options = list(pageLength = 5,
                                              lengthMenu = c(5,10,15)
                                              
                                              ),
                               filter = 'top'
                               )
    })

    
    output$tabla3 <- DT::renderDataTable({
      iris %>% datatable(extensions = 'Buttons',
                         options = list(dom = 'Brftip',
                                        buttons =c('csv')),
                         rownames = FALSE
                         )
          })
    
    output$tabla4 <- DT::renderDataTable({
      mtcars %>% datatable(selection = 'single')
    })
    
    output$tabla_4_single_click <- renderText({
      input$tabla4_rows_selected
    })


    
    output$tabla5 <- DT::renderDataTable({
      mtcars %>% datatable()
    })
    
    output$tabla_5_multi_click <- renderText({
      input$tabla5_rows_selected
    })

    
    output$tabla6 <- DT::renderDataTable({
      mtcars %>% datatable(selection = list(mode='single', target='column'))
    })
    
    output$tabla_6_single_click <- renderText({
      input$tabla6_columns_selected
    })
    
            
    output$tabla7 <- DT::renderDataTable({
      mtcars %>% datatable(selection = list(mode='multiple', target='column'))
    })
    
    output$tabla_7_multi_click <- renderText({
      input$tabla7_columns_selected
    })

    
    
    
    output$tabla8 <- DT::renderDataTable({
      mtcars %>% datatable(selection = list(mode='single', target='cell'))
    })
    
    output$tabla_8_single_click <- renderPrint({
      #c(input$tabla8_rows_selected, input$tabla8_columns_selected)
      input$tabla8_cells_selected
    })
    
    
    output$tabla9 <- DT::renderDataTable({
      mtcars %>% datatable(selection = list(mode='multiple', target='cell'))
    })
    
    output$tabla_9_multi_click <- renderPrint({
      input$tabla9_cells_selected
    })
    
    
    
    
    
    
    
    
    
    
    
    
    
})
