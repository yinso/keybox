create table if not exists keyvals (
  id integer primary key,
  key text unique not null,
  value text not null
  );

