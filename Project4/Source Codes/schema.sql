drop table if exists messages;
create table messages (
    id integer primary key autoincrement,
    text text not null
);
insert into messages (text) values ('Hello from the container!');
