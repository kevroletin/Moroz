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
  start_time TIMESTAMP DEFAULT(current_timestamp),
  description TEXT
);

create table contracts (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  company_id INTEGER NOT NULL REFERENCES companies(id),
  project_id INTEGER REFERENCES projects(id),
  is_active BOOL DEFAULT('true'),

  constraint contracts_unique_constraint
      unique(company_id, project_id)
);

create index contract_company_id_index
  on contracts ( company_id );

create index contracts_project_id_index
  on contracts ( project_id );

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
  project_id INTEGER REFERENCES projects(id),
  estimate_time INTEGER DEFAULT(0),
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
                       REFERENCES user_project_items(id)
);

create table task_dependences (
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
select c.*, projects.name as project, companies.name as company from contracts c 
  left join projects on project_id = projects.id
  left join companies on company_id = companies.id;

create view user_project_items_full  as
  select user_project_items.*, users.name as user 
  from user_project_items
  left join users on user_id = users.id;

create view activity_on_task_full as
  select activity_on_task.*, 
         users.name as user,
         users.id as user_id
  from activity_on_task 
    join user_project_items 
      on user_project_item_id = user_project_items.id
    join users on user_project_items.user_id = users.id;


/* COMMIT; */

CREATE OR REPLACE FUNCTION find_path (INTEGER, INTEGER) 
RETURNS SETOF INTEGER AS $$  
    my ($master, $slave) = @_;
    
    my $plan = spi_prepare(
'SELECT * FROM task_dependences where blocking_task_id = $1', 'INTEGER');
    my @fifo = ($master);
    my %from;

    while (@fifo && !$from{$slave}) {
        my $from = shift @fifo;
	my $sth = spi_query_prepared($plan, $from);
	while (defined ($row = spi_fetchrow($sth))) {
		my $to = $row->{depended_task_id};
		next if defined $from{$to};
		$from{$to} = $from;
		push @fifo, $to;
	}
    }

    my $i = $slave;
    while ($from{$i}) {
	return_next($from{$i});
	$i = $from{$i};
    }
   
    return;
$$ LANGUAGE plperl;

CREATE OR REPLACE FUNCTION check_circular_link()
RETURNS trigger AS $$
    my $master = $_TD->{new}{blocking_task_id};
    my $slave = $_TD->{new}{depended_task_id};

    my $plan = spi_prepare(
'SELECT * FROM task_dependences where blocking_task_id = $1', 'INTEGER');
    my @fifo = ($master);
    my %from;

    while (@fifo && !$from{$slave}) {
        my $from = shift @fifo;
	my $sth = spi_query_prepared($plan, $from);
	while (defined ($row = spi_fetchrow($sth))) {
		my $to = $row->{depended_task_id};
		next if defined $from{$to};
		$from{$to} = $from;
		push @fifo, $to;
	}
    }

    if (defined $from{$slave}) {
        elog(ERRROR, 'circular dependency');
        return "SKIP";
    }
    return;

$$ LANGUAGE plperl;

ALTER TABLE task_dependences
ADD CONSTRAINT check_circular_dependency
CHECK(not path_exists(depended_task_id, blocking_task_id) 
      and blocking_task_id != depended_task_id);


CREATE OR REPLACE FUNCTION can_finish_task (INTEGER, BOOLEAN) 
RETURNS BOOLEAN AS $$  
    my ($task_id, $new_val) = @_;
    return true if $new_val eq 't';
    
    my $plan = spi_prepare( <<SQL
SELECT NOT EXISTS (
  select * from task_dependences td
  join tasks on td.blocking_task_id = tasks.id
  where td.depended_task_id = \$1
  and is_active = true
) as result
SQL
,'INTEGER');

   my $res = spi_exec_prepared($plan, $task_id);	
   
   return $res->{rows}[0]{result};
$$ LANGUAGE plperl;

CREATE OR REPLACE FUNCTION can_open_task (INTEGER, BOOLEAN) 
RETURNS BOOLEAN AS $$  
    my ($task_id, $new_val) = @_;
    return true if $new_val eq 'f';
    
    my $plan = spi_prepare( <<SQL
SELECT NOT EXISTS (
  select * from task_dependences td
  join tasks on td.depended_task_id = tasks.id
  where td.blocking_task_id = \$1
  and is_active = false
) as result
SQL
,'INTEGER');

   my $res = spi_exec_prepared($plan, $task_id);	
   
   return $res->{rows}[0]{result};
$$ LANGUAGE plperl;

ALTER TABLE tasks ADD CONSTRAINT can_finish_task_constraint
CHECK(can_finish_task(id, is_active) and 
      can_open_task(id, is_active));
