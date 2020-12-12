## Proyecto

#### Integrantes

* 20000758 - Hector Alberto Heber Mendia Arriola
* 05244028 - Edwin Estuardo Zapeta Gómez

A continuación archivos de referencia a la aplicación:

* [server.r](https://github.com/HectorMendia/ProductDevelopment/blob/master/ProyectoFinal/server/server.R)
* [ui.r](https://github.com/HectorMendia/ProductDevelopment/blob/master/ProyectoFinal/server/ui.R)

Docker Compose

* [docker-compose](https://github.com/HectorMendia/ProductDevelopment/blob/master/ProyectoFinal/docker-compose.yml)

#### **Estructura** 

* airflow: Archivos de configuración  para Airflow: dockerfile, airflow.cfg, entrypoint.sh requirements.txt.  
* dags: DAGs creados para la carga de los archivos, existe un DAG para cada archivo que se carga a la base de datos
* dashboard: Contiene el archivo Dockerfile para el ShinyServer, este esta basado en ‘rocker/shiny’ y se instalan librerías adicionales para la ejecución del tablero
* database: Contiene los archivos para la base de datos 
    * estructura.sql: archivo con las creaciones de las tablas para almacenar la información proveniente los los csv 
    * db_airflow.sql: configuración de la base de datos que utiliza Airflow

* datainput: Almacenamiento de los archivos de carga utilizados como referencia
* logs: Archivos de registro de la ejecución del tablero de shiny
* monitor: Carpeta que se utiliza para la carga de archivos de entrada, esta carpeta es la que esta configurada como lectura para Airflow
* server: Contiene los archivos para el tablero de shiny (server.r, ui.r) 




#### **Desarrollo** 


**1. Docker**

Se realizo la configuración del archivo Docker-compose.yml que inicia todos los servidores y sus configuraciones asociadas.

* repositorio: Base de datos de PostgreSQL como repositorio de los datos cargados, recibe la información de airflow y la muestra de lectura en el tablero.
* postgres : Base de datos PostgreSQL para uso de Airflow
* webserver: Configuración de Airflow con una compilación personlizada
* dashboard: Servidor con Shiny para el despliegue del tablero.



```yaml
version: '3.8'
services:
    repositorio:
        image: postgres:latest
        environment:
            - POSTGRES_USER=final
            - POSTGRES_PASSWORD=final
            - POSTGRES_DB=final
        restart: always
        ports:
            - 5432:5432
        volumes:
            - ./database/estructura.sql:/docker-entrypoint-initdb.d/db.sql
        logging:
            options:
                max-size: 10m
                max-file: "3"
    postgres:
        image: postgres:9.6
        environment:
            - POSTGRES_USER=airflow
            - POSTGRES_PASSWORD=airflow
            - POSTGRES_DB=airflow
        volumes:
            - ./database/db_airflow.sql:/docker-entrypoint-initdb.d/init.sql
        logging:
            options:
                max-size: 10m
                max-file: "3"

    webserver:
        build: ./airflow
        restart: always
        depends_on:
            - postgres
        environment:
            - LOAD_EX=n
            - EXECUTOR=Local
        logging:
            options:
                max-size: 10m
                max-file: "3"
        volumes:
            - ./dags:/usr/local/airflow/dags
            - ./monitor:/home/airflow/monitor
            - ./airflow/airflow.cfg:/usr/local/airflow/airflow.cfg
        ports:
            - "8080:8080"
        command: webserver
        healthcheck:
            test: ["CMD-SHELL", "[ -f /usr/local/airflow/airflow-webserver.pid ]"]
            interval: 30s
            timeout: 30s
            retries: 3

    dashboard:
      build: ./dashboard
      depends_on:
          - postgres
      ports:
        - 3838:3838
      volumes:
      - ./server:/srv/shiny-server
      - ./logs:/var/log/shiny-server

```


**2. Configuración de DAG**

Se configura la siguiente variable para establecer la ruta de los archivos de entrada.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-5.png">
 
Los siguientes parametros corresponden a las credenciales de conexión a la Base de Datos PostgreSQL.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-6.png">

La siguiente imagen representa el flujo del proceso del DAG cuando se encuentra en ejecución.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-11.png">

A continuación se listan los archivos que se trasladaron con la data correspondiente a casos confirmados, muertes y recuperaciones de COVID-19.

**3. Archivos proveidos**

A continuación se listan los archivos que se trasladaron con la data correspondiente a casos confirmados, muertes y recuperaciones de COVID-19.

* time_series_covid19_confirmed_global.csv
* time_series_covid19_deaths_global.csv
* time_series_covid19_recovered_global.csv

**4. Estructura de la base de datos (PostgreSQL)**

Las tres tablas poseen la misma estructura, se hizo de esta manera por facilidad y manipulación de los datos.

```sql
create table confirmed(
  provincia varchar(50),
  country varchar(50),
  lat numeric(38,8),
  long numeric(38,8),
  dates date,
  value int
);


create table deaths(
  provincia varchar(50),
  country varchar(50),
  lat numeric(38,8),
  long numeric(38,8),
  dates date,
  value int
);


create table recovered(
  provincia varchar(50),
  country varchar(50),
  lat numeric(38,8),
  long numeric(38,8),
  dates date,
  value int
);

```

**5. Transformación de datos y programación de DAG**

El script de python que realiza la transformación requiere de las siguientes librerias, algunas como **pandas** para almacenar los datos en un Dataframe y **airflow** en su mayoría que se encarga de crear workflows de forma programática y, además, planificarlos y monitorizarlos de forma centralizada.

```python
import pandas as pd
from datetime import datetime
from airflow import DAG
from airflow.models import Variable
from airflow.contrib.hooks.fs_hook import FSHook
from airflow.contrib.sensors.file_sensor import FileSensor
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from structlog import get_logger
from airflow.hooks.postgres_hook import PostgresHook

```

Se delaran las siguientes variables con valores por defecto para establecer la conexión a la base de datos y para definir el nombre del CSV que contine los datos. Este ejemplo realiza la carga al motor de base de datos Postgres de los casos confirmados a nivel mundial.

```python
FILE_CONNECTION_ID = "filed"
FILE_NAME = "time_series_covid19_confirmed_global.csv"
```

La siguiente función se utiliza para realizar la transformación de los datos. El proceso se encarga de recorrer el archivo CSV, transformar los datos tipo DATE a un formato específico y de sumarizar los valores filtrados por fecha y país.

```python
    file_path = FSHook(conn_id = FILE_CONNECTION_ID).get_path()
    full_path = f'{file_path}/{FILE_NAME}'
    df = pd.read_csv(full_path, encoding = "ISO-8859-1")
    total_cols = df.keys()
    prov = []
    country = []
    lat = []
    lon = []
    date=[]
    val = []
    
    fila = 0
    for idx,item in df.iterrows():
        fila += 1
        for coldate in total_cols[4:]:
            prov.append(item['Province/State'])
            if str(item['Province/State']) == 'nan':
                country.append(item['Country/Region'])
            else:
                country.append(item['Country/Region'] + '(' + item['Province/State'] + ')')
            
            lat.append(item['Lat'])
            lon.append(item['Long'])
            date_time_obj = datetime.strptime(coldate, '%m/%d/%y')
            date.append(date_time_obj)
            val.append(item[coldate])
    carga = pd.DataFrame({})
    d = {'provincia':prov, 'country': country, 'lat': lat, 'long': lon, 'dates': date, 'value':val}
    carga = pd.DataFrame(data=d)
    locallog = pd.DataFrame({'tipo':['confirmed'], 'fecha':[datetime.now()]})
    resumen = carga.groupby(['dates']).sum()
    resumen = resumen.reset_index()
    resumen['provincia'] = ''
    resumen['country'] = '-Global-'
    resumen['lat'] = None
    resumen['long'] = None
    carga = carga.append(resumen)
    psql_connection = PostgresHook('pgsql').get_sqlalchemy_engine()
    with psql_connection.begin() as connection:
        connection.execute("truncate confirmed")
        carga.to_sql('confirmed', con=connection, if_exists='append', index=False)
        locallog.to_sql('log_carga', con=connection, if_exists='append', index=False)    
```

A continuación se crea el workflow para programar la carga a la base de datos, el proceso consiste en recoger la data transformada e insertarla en la estructura creada en Postgres.

```python       
dag = DAG('confirmed', description='Load COVID confirmed cases',
          default_args={
              'owner': 'hector.mendia',
              'depends_on_past': False,
              'max_active_runs': 1,
              'start_date': days_ago(1)
          },
          schedule_interval='0 1 * * *',
          catchup=True)

file_sensor_task = FileSensor(dag = dag,
                                task_id="readfile_sensor",
                                fs_conn_id=FILE_CONNECTION_ID,
                                filepath=FILE_NAME,
                                poke_intreval=10,
                                timeout=300
                            )

etl_operator = PythonOperator(dag = dag,
                            task_id="etl_confirmed",
                            python_callable =etl_process,
                            provide_context=True
)

file_sensor_task >> etl_operator
```

**6. Shiny App**

**6.1 Vista general de la aplicación**

Al interactuar con los input que se encuentran del lado izquierdo, automáticamente se renderizan los indicadores, gráficas y resto de componentes del panel derecho.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-1.png">

**6.2 Contador de casos confirmados, muertes y recuperados**

Los contadores que se muestran en la parte superior de la aplicación se actualizan dependiendo de la fecha o pais seleccionado.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-2.png">

**6.3 Mapas interactivos**

Cada mapa despliega un marcador sobre el pais que se selecciona y además al posicionarse por encima de la burbuja devuelve la cantidad de casos confirmados, muertes o recuperados, según sea el caso. El tamaño y color de cada burbuja pintada en el mapa varía dependiendo de la cantidad de casos reportados en cada país.

**6.3.1 Mapa de casos confirmados**

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-7.png">

**6.3.2 Mapa de muertes**

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-3.png">

**6.3.3 Mapa de recuperados**

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-8.png">

**6.4 Tendencia de casos confirmados**

La gráfica de líneas muestra el comportamiento de casos confirmados a lo largo de los meses desde que aparecío la enfermedad.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-9.png">

**6.5 Detalle de casos recuperados**

La siguiente tabla muestra el detalle de casos recuperados en un pais específico. En la columna **cantidad** se muestra una franja celeste que varía su intensidad dependiendo del día que más recuperaciones se han presentado.

<img src="https://raw.githubusercontent.com/estuardozapeta/Product-Development-Proyecto/main/image-4.png">