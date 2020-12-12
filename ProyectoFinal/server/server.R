


con <- DBI::dbConnect(odbc::odbc(),
                      Driver   = "PostgreSQL ANSI",
                      Server   = "repositorio",
                      Database = "final",
                      UID      = 'final',
                      PWD      = 'final',
                      Port     = 5432)


data_total <- dbGetQuery(conn= con, statement = "SELECT * from confirmed") #read.csv("confirmed.csv")
data_death <- dbGetQuery(conn= con, statement = "SELECT * from deaths") #read.csv("deaths.csv")
data_recovered <- dbGetQuery(conn= con, statement = "SELECT * from recovered") #read.csv("recovered.csv")


maxdate = dbGetQuery(conn= con, statement = "SELECT to_char(max(dates),'yyyy-mm-dd') from confirmed")
print(maxdate)


default_country <- "Afghanistan"
default_date <- "2020-10-31"

total <- data_total %>% filter(as.Date(dates, "%Y-%m-%d") == default_date & country == default_country) %>% summarise(total = sum(value))
death <- data_death %>% filter(as.Date(dates, "%Y-%m-%d") == default_date & country == default_country) %>% summarise(total = sum(value))
death_data_map <- data_death %>% filter(as.Date(dates, "%Y-%m-%d") == default_date)
recovered <- data_recovered %>% filter(as.Date(dates, "%Y-%m-%d") == default_date & country == default_country) %>% summarise(total = sum(value))
data_plot_series <- data_total %>% filter(country == default_country)

server <- function(input, output) {
    
    output$output_range_date <- renderUI({
        min_date <- data_total %>% mutate(date = ymd(dates)) %>% summarize(value_date = min(date))
        max_date <- data_total %>% mutate(date = ymd(dates)) %>% summarize(value_date = max(date))
        
        sliderInput(
            inputId = "slide_range_date",
            label = "Fecha:",
            min = as.Date(min_date$value_date,"%Y-%m-%d"),
            max = as.Date(max_date$value_date,"%Y-%m-%d"),
            value = as.Date(default_date),
            timeFormat="%Y-%m-%d")
    })
    
    output$output_select_country <- renderUI({
        items_country <- data_total %>% distinct(country)
        selectInput("select_country", "Pais:",
                    choices = items_country)
    })
    
    observe({
        selected_range <- input$slide_range_date
        selected_country <- input$select_country
        
        if (!is.null(selected_range) & !is.null(selected_country)){
            total <- data_total %>% filter(as.Date(dates, "%Y-%m-%d") == selected_range & country == selected_country) %>% summarise(total = sum(value))
            death <- data_death %>% filter(as.Date(dates, "%Y-%m-%d") == selected_range & country == selected_country) %>% summarise(total = sum(value))
            recovered <- data_recovered %>% filter(as.Date(dates, "%Y-%m-%d") == selected_range & country == selected_country) %>% summarise(total = sum(value))
            
            confirmed_data_map <- data_total %>% filter(as.Date(dates, "%Y-%m-%d") == selected_range)
            confirmed_country_select <- confirmed_data_map %>% filter(country == selected_country)
            
            death_data_map <- data_death %>% filter(as.Date(dates, "%Y-%m-%d") == selected_range)
            death_country_select <- death_data_map %>% filter(country == selected_country)
            
            recovered_data_map <- data_recovered %>% filter(as.Date(dates, "%Y-%m-%d") == selected_range)
            recovered_country_select <- recovered_data_map %>% filter(country == selected_country)
            
            getColorConfirmed <- function(data_map) {
                sapply(data_map$value, function(value) {
                    if(value <= 50000) {
                        "#06DEBA"
                    } else if(value <= 200000) {
                        "#0089C4"
                    } else if(value <= 500000) {
                        "#4085A2"
                    }else if(value <= 1000000) {
                        "#0046C0"
                    } else {
                        "#033387"
                    } })
            }
            
            getColorDeath <- function(data_map) {
                sapply(data_map$value, function(value) {
                    if(value <= 5000) {
                        "#FD8D3C"
                    } else if(value <= 35000) {
                        "#FC4E2A"
                    } else if(value <= 50000) {
                        "#E31A1C"
                    }else if(value <= 10000) {
                        "#BD0026"
                    } else {
                        "#800026"
                    } })
            }
            
            getColorRecovered <- function(data_map) {
                sapply(data_map$value, function(value) {
                    if(value <= 5000) {
                        "#BFEC0C"
                    } else if(value <= 35000) {
                        "#A0C608"
                    } else if(value <= 50000) {
                        "#57AF00"
                    }else if(value <= 10000) {
                        "#28A807"
                    } else {
                        "#1A7503"
                    } })
            }
            
            if(selected_country == "-Global-"){
                
                output$covid_confirmed_map <- renderLeaflet({
                    leaflet(confirmed_data_map) %>% 
                        setView(lng = -99, lat = 45, zoom = 2)  %>%
                        addTiles() %>% 
                        addCircles(data = confirmed_data_map, lat = ~ lat, lng = ~ long, radius = ~sqrt(value)*300, weight = 1, label = ~as.character(paste0("Confirmados: ", sep = " ", value)), color = ~getColorConfirmed(confirmed_data_map), fillOpacity = 0.7)
                })
                
                output$covid_death_map <- renderLeaflet({
                    leaflet(death_data_map) %>% 
                        setView(lng = -99, lat = 45, zoom = 2)  %>%
                        addTiles() %>% 
                        addCircles(data = death_data_map, lat = ~ lat, lng = ~ long, radius = ~sqrt(value)*1500, weight = 1, label = ~as.character(paste0("Muertes: ", sep = " ", value)), color = ~getColorDeath(death_data_map), fillOpacity = 0.6)
                })
                
                output$covid_recovered_map <- renderLeaflet({
                    leaflet(recovered_data_map) %>% 
                        setView(lng = -99, lat = 45, zoom = 2)  %>%
                        addTiles() %>% 
                        addCircles(data = recovered_data_map, lat = ~ lat, lng = ~ long, radius = ~sqrt(value)*500, weight = 1, label = ~as.character(paste0("Recuperados: ", sep = " ", value)), color = ~getColorRecovered(recovered_data_map), fillOpacity = 0.7)
                })
                
            }
            else {
                output$covid_confirmed_map <- renderLeaflet({
                    leaflet(confirmed_data_map) %>% 
                        setView(lng = confirmed_country_select$long, lat = confirmed_country_select$lat, zoom = 2)  %>%
                        addTiles() %>% 
                        addCircles(data = confirmed_data_map, lat = ~ lat, lng = ~ long, radius = ~sqrt(value)*300, weight = 1, label = ~as.character(paste0("Confirmados: ", sep = " ", value)), color = ~getColorConfirmed(confirmed_data_map), fillOpacity = 0.7)%>%
                        addMarkers(lng = confirmed_country_select$long, lat = confirmed_country_select$lat)
                })
                
                output$covid_death_map <- renderLeaflet({
                    leaflet(death_data_map) %>% 
                        setView(lng = death_country_select$long, lat = death_country_select$lat, zoom = 2)  %>%
                        addTiles() %>% 
                        addCircles(data = death_data_map, lat = ~ lat, lng = ~ long, radius = ~sqrt(value)*1500, weight = 1, label = ~as.character(paste0("Muertes: ", sep = " ", value)), color = ~getColorDeath(death_data_map), fillOpacity = 0.6)%>%
                        addMarkers(lng = death_country_select$long, lat = death_country_select$lat)
                })
                
                output$covid_recovered_map <- renderLeaflet({
                    leaflet(recovered_data_map) %>% 
                        setView(lng = recovered_country_select$long, lat = recovered_country_select$lat, zoom = 2)  %>%
                        addTiles() %>% 
                        addCircles(data = recovered_data_map, lat = ~ lat, lng = ~ long, radius = ~sqrt(value)*500, weight = 1, label = ~as.character(paste0("Recuperados: ", sep = " ", value)), color = ~getColorRecovered(recovered_data_map), fillOpacity = 0.7)%>%
                        addMarkers(lng = recovered_country_select$long, lat = recovered_country_select$lat)
                })
                
            }
        }
        
        output$output_total <- renderValueBox({
            valueBox(
                formatC(total$total, format = "d", big.mark = ','),
                paste('Total de casos'),
                icon = icon("globe", lib = 'glyphicon'),
                color = "navy"
            )
            
        })
        
        output$output_death <- renderValueBox({
            valueBox(
                formatC(death$total, format = "d", big.mark = ','),
                paste('Muertes'),
                icon = icon("thumbs-down", lib = 'glyphicon'),
                color = "orange"
            )
            
        })
        
        output$output_recovered <- renderValueBox({
            valueBox(
                formatC(recovered$total, format = "d", big.mark = ','),
                paste('Recuperados'),
                icon = icon("thumbs-up", lib = 'glyphicon'),
                color = "aqua"
            )
            
        })
        
    })
    
    data_plot <- reactive({
        selected_country <- input$select_country
        selected_range <- input$slide_range_date
        
        if (!is.null(selected_country) & !is.null(selected_range)){
            data_plot_series <- data_total %>% filter(country == selected_country & as.Date(dates, "%Y-%m-%d") >= selected_range)
            
            columns_table <- data_recovered %>% filter(country == selected_country & as.Date(dates, "%Y-%m-%d") >= selected_range) %>% select(fecha = dates, cantidad = value)
            
            output$render_data_table = DT::renderDataTable({
                
                datatable(columns_table) %>% formatStyle(
                    'cantidad',
                    background = styleColorBar(range(columns_table$cantidad), 'steelblue'),
                    backgroundSize = '100% 90%',
                    backgroundRepeat = 'no-repeat',
                    backgroundPosition = 'center'
                )
                
            })
        }
        
        return(data_plot_series)
        
    })
    
    
    output$render_plot_daily <- renderPlot({
        
        ggplot(data_plot(), aes(x=as.Date(dates, "%Y-%m-%d")), size = 1.3) + 
            geom_line(aes(y=value), color="blue") +
            labs(x="Fecha", y="Total de casos")
    })
    
    
}
