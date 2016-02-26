-- although most of the time there will only be one user, 
create table if not exists users (
  id integer primary key,
  username text unique not null,
  hash text not null
  );

create table if not exists keyvals (
  id integer primary key,
  user_id text not null references users (user_id), -- does sqlite do on update cascade?
  key text not null,
  value text not null,
  unique ( user_id , key )
  );

