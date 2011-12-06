BEGIN;

/* DOMAINS */

create domain role as 
  TEXT NOT NULL
  check (value in ('manager', 'developer'));

/* TABLES and INDEXES */

create table companies (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

create table contracts (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  is_relevant BOOL DEFAULT('true')
);

create table company_contract_items (
/*   id SERIAL PRIMARY KEY, */
  company_id INTEGER REFERENCES companies(id),
  contract_id INTEGER REFERENCES contracts(id)
);

create index company_contract_items_company_id_index
  on company_contract_items ( company_id );

create index company_contract_items_contract_id_index
  on company_contract_items ( contract_id );

create table users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  is_administrator BOOL DEFAULT('false')
);

create table projects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE DEFAULT(current_date),
  description TEXT
);

create table user_project_items (
  id SERIAL PRIMARY KEY,
  project_id INTEGER REFERENCES companies(id),
  user_id INTEGER REFERENCES users(id),
  role ROLE,
  is_active BOOL DEFAULT('true')
);

create table tasks (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  estimate_time TIME,
  is_active BOOL DEFAULT('true')
);

create table activity_on_task (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  start_time TIMESTAMP DEFAULT(current_timestamp),
  finish_time TIMESTAMP DEFAULT(NULL),
  tasks INTEGER REFERENCES companies(id),
  user_project_item_id INTEGER REFERENCES user_project_items(id)
);

create table task_dependences  (
/*  id SERIAL PRIMARY KEY, */
  blocking_task_id INTEGER REFERENCES tasks(id),
  depended_task_id INTEGER REFERENCES tasks(id)
);

create index task_dependences_blocking_task_id_index
  on task_dependences ( blocking_task_id );

create index task_dependences_depended_task_id_index
  on task_dependences ( depended_task_id );


COMMIT;
