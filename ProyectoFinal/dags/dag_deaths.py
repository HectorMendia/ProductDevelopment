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



FILE_CONNECTION_ID = "filed"
FILE_NAME = "time_series_covid19_deaths_global.csv"


def etl_process(**kwargs):
    #logger.info('Inicio: deaths')
    print(11)
    #file_path = FSHook(FILE_CONNECTION_ID).get_path()
    file_path = FSHook(conn_id = FILE_CONNECTION_ID).get_path()
    full_path = f'{file_path}/{FILE_NAME}'
    df = pd.read_csv(full_path, encoding = "ISO-8859-1")
    total_cols = df.keys()
    #logger.info('Lectura: deaths')
    print(22)
    prov = []
    country = []
    lat = []
    lon = []
    date=[]
    val = []
    # transformacion de datos
    fila = 0
    for idx,item in df.iterrows():
        fila += 1
        for coldate in total_cols[4:]:
            prov.append(item['Province/State'])
            # country.append(item['Country/Region'])
            if str(item['Province/State']) == 'nan':
                country.append(item['Country/Region'])
            else:
                country.append(item['Country/Region'] + '(' + item['Province/State'] + ')')

            lat.append(item['Lat'])
            lon.append(item['Long'])
            date_time_obj = datetime.strptime(coldate, '%m/%d/%y')
            date.append(date_time_obj)
            val.append(item[coldate])
    print(fila)
    carga = pd.DataFrame({})
    d = {'provincia':prov, 'country': country, 'lat': lat, 'long': lon, 'dates': date, 'value':val}
    carga = pd.DataFrame(data=d)
    locallog = pd.DataFrame({'tipo':['deaths'], 'fecha':[datetime.now()]})

    #logger.info('Tranformado')
    resumen = carga.groupby(['dates']).sum()
    resumen = resumen.reset_index()
    resumen['provincia'] = ''
    resumen['country'] = '-Global-'
    resumen['lat'] = None
    resumen['long'] = None
    carga = carga.append(resumen)
    print('Transformado')

    psql_connection = PostgresHook('pgsql').get_sqlalchemy_engine()
    with psql_connection.begin() as connection:
        connection.execute("truncate deaths")
        carga.to_sql('deaths', con=connection, if_exists='append', index=False)
        locallog.to_sql('log_carga', con=connection, if_exists='append', index=False)

    #logger.info('Cargado')
    #logger.info(f"Rows inserted {len(df.index)}")



dag = DAG('deaths', description='Load COVID deaths cases',
          default_args={
              'owner': 'grupo.dos',
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
                                timeout=300,
                                #provide_context = True
                            )

etl_operator = PythonOperator(dag = dag,
                            task_id="etl_deaths",
                            python_callable =etl_process,
                            provide_context=True
)


file_sensor_task >> etl_operator