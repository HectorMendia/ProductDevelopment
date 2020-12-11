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

create table log_carga(
    tipo varchar(25),
    fecha date
)

