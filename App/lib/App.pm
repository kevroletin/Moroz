package App;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use App::Database;
use App::Validate;

use Data::Dumper::Concise;

our $VERSION = '0.1';

my $forms;
my $current_form;


sub to_forms {
    my $form_name = $_[0];
    sub {
        my $res = {};
        $res->{$_} = param($_) for @_;
        $forms->{$form_name} = $res;
        $res
    }
}

sub from_forms { $forms->{$_[0]} }


sub log_sql {
#     print STDERR "**********SQL: " . $_[0] || '' . "\n";
#     print "<pre>$_[0]</pre>";
     $_[0]
}

sub set_current_form {
    $current_form = $_[0];
    $current_form ? "form_$current_form" : ''
}

sub get_from_current_form {
    return $forms unless defined $_[0];
    if ($current_form) {
        my $cf = $forms->{$current_form};
        return defined $cf ? $cf->{$_[0]} : ''
    }
}

sub is_admin { session('user')->{is_admin} }

sub admin_only {
    my $s = shift;
    sub {
        unless (session('user')->{is_admin}) {
            return send_error("Not admin", 403)
        }
        $s->(@_);
    }
}

sub role {
    my $projext_id = vars->{project_id};
    my $user_id = session('user_id');
    my $q = <<SQL
select role, id from user_project_items
  where project_id = $projext_id
  and user_id = $user_id
SQL
        ;
    log_sql($q);
    my $sth = database->prepare($q);
    $sth->execute();
    my $res = $sth->fetchrow_hashref();
    var user_project_item_id => $res->{id};
    $res->{role} || undef;
}

sub is_manager {
    my $role = role();
    defined $role && $role eq 'manager'
}

sub works_on_project_only {
    my $s = shift;
    sub {
        var role => role();
        unless (defined vars->{role}) {
            return send_error("Not works on this project", 403)
        }
        $s->(@_);
    }
}

sub manager_only {
    my $s = shift;
    sub {
        unless (is_manager()) {
            return send_error("Not manager on this project", 403)
        }
        $s->(@_);
    }
}

sub fetch_user_activity {
    my $user_id = $_[0] || session('user_id');
    my $sth = database()->prepare( log_sql <<SQL
select a.* from users u
  join user_project_items up on u.id = up.user_id
  join activity_on_task a on up.id = a.user_project_item_id
where u.id = ?
  and a.finish_time is null
SQL
);
    $sth->execute($user_id);
    my $act = $sth->fetchrow_hashref();
}


hook 'before' => sub {
    if (session('user_id')) {
        # FIXME:
        session 'user' => database()->quick_select(
                            'users', {id => session('user_id')})
    }

    if (!session('user') &&
        request->path_info !~ m{^/(logout)|(login)})
    {
        var requested_path => request->path_info;
        request->path_info('/login');
    }
};

hook 'before_template' => sub {
    my $t = shift;
    $t->{user} = session('user');
    $t->{session} = \&session;
    $t->{curr_f} = \&set_current_form;
    $t->{f} = \&get_from_current_form;
    $t->{db} = database();
    $t->{log_sql} = \&log_sql;
    $t->{is_manager} = \&is_manager;

    $t->{error} ||= $DBI::errstr if $DBI::errstr;
};

get '/' => sub {
    request->path_info("/user/" . session('user_id'));
    pass
};

get '/login' => sub {
    delete $forms->{login};
    template 'login' => {
        message => 'please, login'
    };
};

post '/login' => sub {
    my $f = to_forms('login')->(qw(name password));
    my $usr;
    eval {
        $usr = database()->quick_select('users', $f)
    };
    my ($err, $msg);
    # TODO: form validation
    if (!$usr || $@) {
        $err = 'wrong user name or password';
        session()->destroy();
    } else {
        session(user_id => $usr->{id});
        session(user => $usr);
        if (vars()->{requested_path}) {
            return redirect( vars->{requested_path} )
        }
        $msg = 'logined'
    }
    template 'login' => {
        message => $msg,
        error => $err
    };
};

any ['get', 'post'] => '/logout' => sub {
    my $msg;
    if (session('user')) {
        $msg = 'logout for ' . session('user')->{name} . ': ok'
    } else {
        $msg = 'was not logined'
    }
    session()->destroy();
    template 'login' => { message => $msg };
};


prefix '/user' => sub {

    get 's' => sub {
        my @q = database()->quick_select('users_full', {});
        template 'users' => { users => \@q };
    };

    get 's/add' => admin_only sub {
        delete $forms->{user};
        template 'user' => { action => '/users/add' };
    };

    post 's/add' => admin_only sub {
        my $f = to_forms('user')->(qw(name password is_admin company_id));
        my $user_id;
        eval{
            $user_id = db()->insert('users', $f)
        };
        if ($@) {
            template 'user' => { action => '/users/add' }
        } else {
            redirect '/users'
        }
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $user;
        if (@$p > 0) {
            eval {
                $user = database()->quick_select('users', {id => $id});
            };
            return send_error("Not found", 404) if !$user || $@;
            var user => $user;
            var user_id => $id;
            return pass
        }
        eval {
            $user = database()->quick_select('users_full', {id => $id})
        };
        return send_error("Not found", 404) if !$user || $@;
        $forms->{user} = $user;
        template 'user' => { action => undef };
    };

    get '/*/edit' => sub {
        my ($id) = splat();
        unless (is_admin() || session('user')->{id} eq $id) {
            return send_error("Not allowed", 403)
        }
        $forms->{user} = vars->{user};
        template 'user' => { action => "/user/$id/edit" };
    };

    post '/*/edit' => sub {
        my $id = vars->{user_id};
        unless (is_admin() || session('user')->{id} eq $id) {
            return send_error("Not allowed", 403)
        }
        my @p = is_admin() ? ('password', 'is_admin', 'company_id') :
                              'password' ;
        my $f = to_forms('user')->(@p);
        eval {
            $forms->{user} = db()->update('users', $f, $id)
        };
        template 'user' => { action => "/user/$id/edit" };
    };

    post '/*/delete' => admin_only sub {
        eval {
            db()->delete('users', vars->{user_id});
        };
        if ($@) {
            return template 'error'
        }
        redirect '/users'
    };

};

prefix '/compan' => sub {

    get 'ies' => sub {
        my @q = database()->quick_select('companies', {});
        template 'companies' => { companies => \@q };
    };

    get 'ies/add' => admin_only sub {
        delete $forms->{company};
        template 'company' => { action => '/companies/add' };
    };

    post 'ies/add' => admin_only sub {
        my $f = to_forms('company')->(qw(name));
        # TODO: process errors
        eval {
            db()->insert('companies', $f)
        };
        if ($@) {
            template 'company' => { action => '/companies/add' };
        } else {
            redirect '/companies'
        }
    };

    any ['get', 'post'] => 'y/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $comp;
        eval {
            $comp = database()->quick_select('companies', {id => $id})
        };
        return send_error("Not found", 404) if !$comp || $@;
        var company => $comp;
        var company_id => $id;
        if (@$p > 0) {
            return send_error("Not allowed", 403) unless is_admin();
            return pass
        }

        $forms->{company} = $comp;
        template 'company' => { action => undef };
    };

    get 'y/*/edit' => sub {
        my ($id) = splat();
        $forms->{company} = vars->{company};
        template 'company' => { action => "/company/$id/edit" };
    };

    post 'y/*/edit' => sub {
        my $id = vars->{company_id};
        my $f = to_forms('company')->('name');
        eval {
            $forms->{company} = db()->update('companies', $f, $id);
        };
        template 'company' => { action => "/company/$id/edit" }
    };

    post 'y/*/delete' => admin_only sub {
        eval {
            db()->delete('companies', vars->{company_id})
        };
        if ($@) {
            return template 'error'
        }
        redirect '/companies'
    };

};


prefix '/project' => sub {

    get 's' => sub {
        my @q = database()->quick_select('projects', {});
        template 'projects' => { projects => \@q };
    };

    get 's/add' => admin_only sub {
        delete $forms->{project};
        template 'project' => { action => '/projects/add' };
    };

    post 's/add' => admin_only sub {
        my $f = to_forms('project')->(qw(name description));
        # TODO: process errors
        eval {
            db()->insert('projects', $f)
        };
        if ($@) {
            template 'project' => { action => '/projects/add' }
        } else {
            redirect '/projects'
        }
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $comp;
        eval {
            $comp = database()->quick_select('projects', {id => $id})
        };
        return send_error("Not found", 404) if !$comp || $@;
        var project => $comp;
        var project_id => $id;
        return pass if @$p > 0;

        $forms->{project} = $comp;
        template 'project' => { action => undef };
    };

    get '/*/edit' => admin_only sub {
        my ($id) = splat();
        $forms->{project} = vars->{project};
        template 'project' => { action => "/project/$id/edit" };
    };

    post '/*/edit' => admin_only sub {
        my $id = vars->{project_id};
        my $f = to_forms('project')->('description');
        eval {
            $forms->{project} = db()->update('projects', $f, $id)
        };
        template 'project' => { action => "/project/$id/edit" }
    };

    post '/*/delete' => admin_only sub {
        eval {
            db()->delete('projects', vars->{project_id})
        };
        if ($@) {
            return template 'error'
        }
        redirect '/projects'
    };

    get '/*/companies' => sub {
        my ($project_id) = splat;
        my $q = <<SQL
select * from companies where id in (
  select company_id from contracts
  where project_id = $project_id
)
SQL
;
        my $sth = database()->prepare($q);
        $sth->execute();
        my @comp;
        while(my $r = $sth->fetchrow_hashref()) { push @comp, $r };
        template 'companies' => { companies => \@comp };
    };

    get '/*/tasks' => sub {
        my ($id) = splat;
        my $sth = database()->prepare(
            "select * from tasks where project_id = $id");
        $sth->execute();
        template "/project/tasks" => {
            tasks_sth => $sth,
            project_id => $id,
            project => vars->{project},
            can_modify => is_manager()
        }
    };

    get '/*/tasks/add' => manager_only sub {
        my ($project_id) = splat;
        delete $forms->{task};
        template 'project/task_add' => {
            action => "add",
            project_id => $project_id,
            project => vars->{project}
        }
    };

    post '/*/tasks/add' => manager_only sub {
        my ($project_id) = splat;
        my $f = to_forms('task')->('name', 'estimate_time');
        $f->{project_id} = $project_id;
        eval {
            database()->quick_insert('tasks', $f)
        };
        if ($@) {
            return template 'project/task_add' => {
                action => "add",
                project_id => $project_id,
                project => vars->{project}
            }
        }
        redirect "project/$project_id/tasks";
    };

    any ['get', 'post'] => '/*/task/**' => sub {
        my ($project_id, $p) = splat;
        my $task_id = shift $p;
        my $task;
        eval {
            $task = database()->quick_select(
                                 'tasks', {id => $task_id});
        };
        return send_error('not found', 404) if !$task || $@;
        if (@$p > 0) {
            var task => $task;
            var task_id => $task_id;
            return pass
        }

        $forms->{task} = $task;
        template 'project/task' => {
            action => undef,
            project_id => $project_id,
            project => vars->{project}
        }
    };

    get '/*/task/*/edit' => manager_only sub {
        my ($project_id, $task_id) = splat;
        $forms->{task} = vars->{task};
        template 'project/task' => {
            action => "edit",
            project_id => $project_id,
            project => vars->{project}
        }
    };

    post '/*/task/*/edit' => manager_only sub {
        my ($project_id, $task_id) = splat;
        my $f = to_forms('task')->('estimate_time', 'is_active');
        $f->{is_active} ||= 'false';
        my $u;
        eval {
             $u = db()->update('tasks', $f, $task_id)
        };
        if ($u) {
            $forms->{task} = $u
        } else {
            $forms->{task} = vars->{task};
        }
        template 'project/task' => {
            action => "edit",
            project_id => $project_id,
            project => vars->{project}
        }
    };

    post '/*/task/*/delete' => manager_only sub {
        my ($project_id, $task_id) = splat;
        eval {
            database()->quick_delete('tasks', { id => $task_id});
        };
        return template 'error' if $@;
        redirect "project/$project_id/tasks";
    };

    post '/*/task/*/link' => manager_only sub {
        my ($project_id, $task_id) = splat;
        my $another_task_id = param('another_task_id');
        my $sth = database()->prepare("insert into task_dependences values (?, ?)");
        eval {
            if (param('link_type') eq 'blocked_by') {
                $sth->execute($another_task_id, $task_id)
            } else {
                $sth->execute($task_id, $another_task_id)
            }
        };
        if ($@) {
            return template 'project/task' => {
                action => "edit",
                project_id => $project_id,
                project => vars->{project}
            }
        }
        redirect "project/$project_id/task/$task_id/edit";
    };

    post '/*/task/*/unlink' => manager_only sub {
        my ($project_id, $task_id) = splat;
        my $another_task_id = param('another_task_id');
        my $sth = database()->prepare("delete from task_dependences " .
                                      "where blocking_task_id = ? and depended_task_id = ?");
        eval {
            if (param('link_type') eq 'blocked_by') {
                $sth->execute($another_task_id, $task_id)
            } else {
                $sth->execute($task_id, $another_task_id)
            }
        };
        if ($@) {
            return template 'project/task' => {
                action => "edit",
                project_id => $project_id,
                project => vars->{project}
            }
        }
        redirect "project/$project_id/task/$task_id/edit";
    };

    get '/*/task/*/activities' => sub {
        my ($project_id, $task_id) = splat;
        my $q = "select * from activity_on_task_full where task_id = $task_id";
        my $sth = database()->prepare($q);
        $sth->execute();
        my @act;
        while (my $u = $sth->fetchrow_hashref()) { push @act, $u }
        template "project/task/activities" => {
            activities => \@act,
            project_id => $project_id,
            task_id => $task_id,
            role => role(),
            work_on_activity => fetch_user_activity()
        }
    };

    get '/*/task/*/activities/add' => works_on_project_only sub {
        my ($project_id, $task_id) = splat;
        template "project/task/activity_add" => {
            project_id => $project_id,
            task_id => $task_id,
            role => vars->{role}
        }
    };

    post '/*/task/*/activities/add' => works_on_project_only sub {
        my ($project_id, $task_id) = splat;
        my $f = to_forms('activity')->(
                    qw(name description user_project_item_id));
        $f->{task_id} = $task_id;
        if (vars->{role} eq 'developer') {
            $f->{user_project_item_id} =
                vars->{user_project_item_id}
        }

        # Search for unfinished tasks
        my $sth = database()->prepare( log_sql <<SQL
select a.* from user_project_items up
  join activity_on_task a on up.id = a.user_project_item_id
where up.id = ?
  and a.finish_time is null
SQL
);      my $act;
        eval {
            $sth->execute($f->{user_project_item_id});
            $act = $sth->fetchrow_hashref();
            db()->insert('activity_on_task', $f)
        };
        if ($@ || $act) {
            return template "project/task/activity_add" => {
                project_id => $project_id,
                task_id => $task_id,
                role => vars->{role},
                error => ($act ?
                    "User already working on activity $act->{name} with id=$act->{id}" :
                    undef)
            }
        }
        redirect "/project/$project_id/task/$task_id/activities"
    };

    any ['get', 'post'] => '/*/task/*/activity/**' => sub {
        my ($project_id, $task_id, $p) = splat;
        my $activity_id = shift $p;
        var activity_id => $activity_id;
        my $act;
        eval {
            $act = database()->quick_select(
                'activity_on_task_full', { id => $activity_id})
        };
        send_error("Activity not found", 404) if !$act || $@;
        var activity => $act;

        my $user_id = session('user_id');
        my $sth = database()->prepare( log_sql <<SQL
select $user_id in (
  select user_id from user_project_items
  where id = $act->{user_project_item_id}
)
SQL
);      $sth->execute();
        my $can_modify = $sth->fetchrow_array();
        $can_modify ||= is_manager();
        var can_modify_activity => $can_modify;

        if (@$p) {
            unless ($can_modify) {
                return send_error('Not allowed', 403)
            }
            return pass
        }

        $forms->{activity} = vars->{activity};
        template "project/task/activity" => {
            project_id => $project_id,
            task_id => $task_id,
            can_modify => $can_modify
        }
    };

    get '/*/task/*/activity/*/edit' => sub {
        my ($project_id, $task_id, $act_id) = splat;
        $forms->{activity} = vars->{activity};
        template "project/task/activity" => {
            project_id => $project_id,
            task_id => $task_id,
            can_modify => vars->{can_modify_activity},
            action => 'edit'
        }
    };

    post '/*/task/*/activity/*/edit' => sub {
        my ($project_id, $task_id, $act_id) = splat;
        my $f = to_forms('activity')->(qw(description));

        eval {
            $forms->{activity} = db()->update('activity_on_task',
                                          $f, $act_id);
        };
        template "project/task/activity" => {
            project_id => $project_id,
            task_id => $task_id,
            can_modify => vars->{can_modify_activity},
            action => 'edit'
        }
    };

    post '/*/task/*/activity/*/open' => sub {
        my ($project_id, $task_id, $act_id) = splat;
        my $sth = database()->prepare( log_sql <<SQL
update activity_on_task set finish_time = null
where id = $act_id
SQL
);
        eval {
            $sth->execute()
        };
        return template 'error' if $@;

        redirect "/project/$project_id/task/$task_id/activity/$act_id"
    };

    post '/*/task/*/activity/*/close' => sub {
        my ($project_id, $task_id, $act_id) = splat;
        my $sth = database()->prepare( log_sql <<SQL
update activity_on_task set finish_time = current_timestamp
where id = $act_id
SQL
);
        eval {
            $sth->execute()
        };
        return template 'error' if $@;

        redirect "/project/$project_id/task/$task_id/activity/$act_id"
    };

#    post '/*/task/*/activity/*/delete' => sub {
#        return 'TODO'
#    };

    get '/*/users' => sub {
        my ($project_id) = splat;
        template 'project/users' => {
            project_id => $project_id
        }
    };

    post '/*/users/add' => admin_only sub {
        my ($project_id) = splat;
        my $f = to_forms('user_project_item')->('role', 'user_id');
        $f->{project_id} = $project_id;
        eval {
            database()->quick_insert('user_project_items', $f)
        };
        if ($@) {
            return template 'project/users' => {
                project_id => $project_id
            }
        }
        redirect "project/$project_id/users";
    };

    post '/*/users/delete' => admin_only sub {
        my ($project_id) = splat;
        my $f = { project_id => $project_id,
                  user_id => param('user_id') };
        eval {
            database()->quick_delete('user_project_items', $f)
        };
        return template 'error' if $@;
        redirect "project/$project_id/users";
    };

};

prefix '/contract' => sub {

    get 's' => sub {
        my @q = database()->quick_select('contracts_full', {});
        template 'contracts' => { contracts => \@q };
    };

    get 's/add' => admin_only sub {
        delete $forms->{contract};
        template 'contract' => { action => '/contracts/add' };
    };

    post 's/add' => admin_only sub {
        my $f = to_forms('contract')->(
                      qw(name company_id project_id));
        eval {
            db()->insert('contracts', $f)
        };
        if ($@) {
            template 'contract' => { action => '/contracts/add' };
        } else {
            redirect "/contracts"
        }
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $comp;
        if (@$p > 0) {
            eval {
                $comp = database()->quick_select('contracts',
                                                {id => $id})
            };
            return send_error("Not found", 404) if !$comp || $@;
            var contract => $comp;
            var contract_id => $id;
            pass
        }

        eval {
            $comp = database()->quick_select('contracts_full',
                                            {id => $id})
        };
        return send_error("Not found", 404) if !$comp || $@;
        $forms->{contract} = $comp;
        template 'contract' => { action => undef };
    };

    get '/*/edit' => admin_only sub {
        my ($id) = splat();
        $forms->{contract} = vars->{contract};
        template 'contract' => { action => "/contract/$id/edit" };
    };

    post '/*/edit' => admin_only sub {
        my $id = vars->{contract_id};
        my $f = to_forms('contract')->(
                  'project_id', 'company_id', 'is_active');
        eval {
            $forms->{contract} = db()->update('contracts', $f, $id)
        };

        template 'contract' => { action => "/contract/$id/edit" };
    };

    post '/*/delete' => admin_only sub {
        eval {
            db()->delete('contracts', vars->{contract_id})
        };
        if ($@) {
            return template 'error'
        }
        redirect '/contracts'
    };

=begin comment

    post '/*/companies/add' => admin_only sub {
        my ($contract_id) = splat;
        my ($company_id) = param('company_id');
        database()->quick_insert('company_contract_items',
                                 {company_id => $company_id,
                                  contract_id => $contract_id});
        redirect "/contract/$contract_id/edit"
    };

    post '/*/company/*/delete' => admin_only sub {
        my ($contract_id, $company_id) = splat;
        database()->quick_delete('company_contract_items',
                                 {company_id => $company_id,
                                  contract_id => $contract_id});
        redirect "/contract/$contract_id/edit"
    };

    get '/*/company/*/users' => sub {
        my ($contract_id, $company_id) = splat;
        my $company = database()->quick_select(
                          'companies', {id => $company_id});
        template 'contract/company/users' => {
            contract => vars->{contract},
            company => vars->{company}
        };
    };

=cut comment

};

get '/activities' => sub {

    my $f = to_forms('filter')->(qw(user_id project_id task_id));
    my (@f, @values);
    for (['user_id', 'u.id'], ['project_id', 'p.id'], ['task_id', 't.id']) {
        if ($f->{$_->[0]}) {
            push @f, "$_->[1] = ?";
            push @values, $f->{$_->[0]};
        } else {
            delete $f->{$_}
        }
    }
    my $where = join "\nand ", @f;
    $where = "\nwhere $where " if $where;

    my $sth = database()->prepare( log_sql <<SQL
select a.*,
       u.id as user_id,
       u.name as user,
       p.id as project_id,
       p.name as project,
       t.id as task_id,
       t.name as task,
       COALESCE(current_timestamp, finish_time) - a.start_time as duration
 from activity_on_task a
  join tasks t on t.id = a.task_id
  join user_project_items up on a.user_project_item_id = up.id
  join projects p on p.id = up.project_id
  join users u on u.id = up.user_id
$where
  order by id
SQL
);

    my $dur_sth = database()->prepare( log_sql <<SQL
select sum(COALESCE(current_timestamp, finish_time) - a.start_time)
 from activity_on_task a
  join tasks t on t.id = a.task_id
  join user_project_items up on a.user_project_item_id = up.id
  join projects p on p.id = up.project_id
  join users u on u.id = up.user_id
$where
SQL
);

    eval {
        $sth->execute(@values);
        $dur_sth->execute(@values);
    };
    if ($@) {
        return template 'error'
    }

    my $users_sth = database()->prepare( 'select id, name from users order by name' );
    $users_sth->execute();
    my $projects_sth = database()->prepare( 'select id, name from projects order by name' );
    $projects_sth->execute();
    my $tasks_sth = database()->prepare( 'select id, name from tasks order by name' );
    $tasks_sth->execute();

    template 'activities' => {
        activities_sth => $sth,
        users_sth => $users_sth,
        tasks_sth => $tasks_sth,
        projects_sth => $projects_sth,
        duration => $dur_sth->fetchrow_array()
    }
};

any '/**' => sub { send_error('not found', 404) };



1;
