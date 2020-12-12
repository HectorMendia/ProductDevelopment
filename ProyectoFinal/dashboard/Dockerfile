FROM rocker/shiny:latest

RUN apt-get update \
  && apt-get install -y --no-install-recommends libmysqlclient-dev

RUN apt-get install unixodbc unixodbc-dev --install-suggests --force-yes

RUN R -e "install.packages(c('DBI','dplyr', 'DT', 'lubridate', 'shinydashboard', 'leaflet', 'leaflet.extras', 'odbc'))"





