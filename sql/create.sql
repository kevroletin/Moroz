/* BEGIN; */

/* DOMAINS */

create domain role as 
  TEXT NOT NULL
  check (value in ('manager', 'developer'));

/* TABLES and INDEXES */

create table companies (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

create table users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  password TEXT NOT NULL,
  company_id INTEGER REFERENCES companies(id),
  is_admin BOOL DEFAULT('false')
);

create table projects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE DEFAULT(current_date),
  description TEXT
);

create table contracts (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  project_id INTEGER REFERENCES projects(id),
  is_relevant BOOL DEFAULT('true')
);

create table company_contract_items (
/*   id SERIAL PRIMARY KEY, */
  company_id INTEGER NOT NULL REFERENCES companies(id), 
  contract_id INTEGER NOT NULL REFERENCES contracts(id),

  constraint company_contract_items_unique_constraint
      unique(company_id, contract_id)
);

create index company_contract_items_company_id_index
  on company_contract_items ( company_id );

create index company_contract_items_contract_id_index
  on company_contract_items ( contract_id );

create table user_project_items (
  id SERIAL PRIMARY KEY,
  project_id INTEGER REFERENCES projects(id),
  user_id INTEGER REFERENCES users(id),
  role ROLE,
/*  is_active BOOL DEFAULT('true') */
  constraint user_project_items_unique_constraint
      unique(project_id, user_id)
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
  task_id INTEGER NOT NULL REFERENCES tasks(id),
  user_project_item_id INTEGER NOT NULL 
                       REFERENCES user_project_items(id),

  constraint activity_on_task_unique_refs_constraint
      unique(task_id, user_project_item_id)
);

create table task_dependences  (
/*  id SERIAL PRIMARY KEY, */
  blocking_task_id INTEGER NOT NULL REFERENCES tasks(id),
  depended_task_id INTEGER NOT NULL REFERENCES tasks(id),

  constraint task_dependences_unique_constraint
      unique(blocking_task_id, depended_task_id)
);

create index task_dependences_blocking_task_id_index
  on task_dependences ( blocking_task_id );

create index task_dependences_depended_task_id_index
  on task_dependences ( depended_task_id );


create view users_full as
select u.id, u.name, u.is_admin, c.name as company, u.company_id 
from users u
  left join companies c on u.company_id = c.id;

create view contracts_full  as
select c.*, projects.name as project from contracts c 
  left join projects on project_id = projects.id;

/* COMMIT; */
