package App;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use App::Database;

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
    #    print "**********SQL: " . $_[0] || '' . "\n"
    print "<pre>$_[0]</pre>"
}

sub set_current_form {
    $current_form = $_[0];
    $current_form ? "form_$current_form" : ''
}

sub get_from_current_form {
    return $forms unless @_;
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

sub is_manager {
    my $projext_id = vars->{project_id};
    my $user_id = session('user_id');
    my $q = <<SQL
select $user_id in (
  select user_id from user_project_items 
  where project_id = $projext_id
)
SQL
        ;
    log_sql($q);
    my $sth = database->prepare($q);
    $sth->execute();
    $sth->fetchrow_array();
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
};

get '/' => sub {
    template 'index' => {
        title => 'mega title'
    };
};

get '/login' => sub {
    template 'login' => {
        message => 'please, login'
    };
};

post '/login' => sub {
    my $f = to_forms('login')->(qw(name password));
    my $usr = database()->quick_select('users', $f);
    my ($err, $msg);
    # TODO: form validation
    unless ($usr) {
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
        # TODO: process errors
        my $user_id = db()->insert('users', $f);
        redirect '/users';
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        if (@$p > 0) {
            my $user = database()->quick_select('users', {id => $id});
            return send_error("Not found", 404) unless ($user);
            var user => $user;
            var user_id => $id;
            return pass
        }
        my $user = database()->quick_select('users_full', {id => $id});
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
        db()->update('users', $f, $id);

        $forms->{user} =
            database()->quick_select('users', {id => $id});
        template 'user' => { action => "/user/$id/edit" };
    };

    post '/*/delete' => admin_only sub {
        db()->delete('users', vars->{user_id});
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
        my $user_id = db()->insert('companies', $f);
        redirect '/companies';
    };

    any ['get', 'post'] => 'y/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $comp = database()->quick_select('companies', {id => $id});
        return send_error("Not found", 404) unless ($comp);
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
        db()->update('companies', $f, $id);

        $forms->{company} =
            database()->quick_select('companies', {id => $id});
        template 'company' => { action => "/company/$id/edit" };
    };

    post 'y/*/delete' => admin_only sub {
        db()->delete('companies', vars->{company_id});
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
        my $user_id = db()->insert('projects', $f);
        redirect '/projects';
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $comp = database()->quick_select('projects', {id => $id});
        return send_error("Not found", 404) unless ($comp);
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
        db()->update('projects', $f, $id);

        $forms->{project} =
            database()->quick_select('projects', {id => $id});
        template 'project' => { action => "/project/$id/edit" };
    };

    post '/*/delete' => admin_only sub {
        db()->delete('projects', vars->{project_id});
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
            project_id => $id
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
        database()->quick_insert('tasks', $f);
        redirect "project/$project_id/tasks";
    };

    get '/*/task/*'=> sub {
        my ($project_id, $task_id) = splat;
        my $task = database()->quick_select(
                                 'tasks', {id => $task_id});
        return send_error('not found', 404) unless $task;
        $forms->{task} = $task;
        template 'project/task' => {
            action => undef,
            project_id => $project_id,
            project => vars->{project}
        }
    };

    any ['get', 'post'] => '/*/task/**' => sub {
        my ($project_id, $p) = splat;
        my $task_id = shift $p;
        my $task = database()->quick_select(
                                 'tasks', {id => $task_id});
        return send_error('not found', 404) unless $task;
        if (@$p > 0) {
            var task => $task;
            var task_id => $task_id;
            return pass
        }

        template 'project/users' => {
           project => vars->{project},
           project_id => vars->{project_id}
    };

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
        database()->quick_update('tasks', { id => $task_id},  $f);
        $forms->{task} = database()->quick_select(
                                         'tasks', {id => $task_id});
        template 'project/task' => {
            action => "edit",
            project_id => $project_id,
            project => vars->{project}
        }
    };

    post '/*/task/*/delete' => manager_only sub {
        my ($project_id, $task_id) = splat;
        database()->quick_delete('tasks', { id => $task_id});
        redirect "project/$project_id/tasks";
    };

    post '/*/task/*/link' => manager_only sub {
        my ($project_id, $task_id) = splat;
        my $another_task_id = param('another_task_id');
        my $sth = database()->prepare("insert into task_dependences values (?, ?)");
        if (param('link_type') eq 'blocked_by') {
            $sth->execute($another_task_id, $task_id)
        } else {
            $sth->execute($task_id, $another_task_id)
        }
        redirect "project/$project_id/task/$task_id/edit";
    };

    post '/*/task/*/unlink' => manager_only sub {
        my ($project_id, $task_id) = splat;
        my $another_task_id = param('another_task_id');
        my $sth = database()->prepare("delete from task_dependences " .
                                      "where blocking_task_id = ? and depended_task_id = ?");
        if (param('link_type') eq 'blocked_by') {
            $sth->execute($another_task_id, $task_id)
        } else {
            $sth->execute($task_id, $another_task_id)
        }
        redirect "project/$project_id/task/$task_id/edit";
    };

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
        database()->quick_insert('user_project_items', $f);
        redirect "project/$project_id/users";
    };

    post '/*/users/delete' => admin_only sub {
        my ($project_id) = splat;
        my $f = { project_id => $project_id,
                  user_id => param('user_id') };
        database()->quick_delete('user_project_items', $f);
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
        template 'contract_add' => { action => '/contracts/add' };
    };

    post 's/add' => admin_only sub {
        my $f = to_forms('contract')->(
                      qw(name company_id project_id));
        # TODO: process errors
        my $contract_id = db()->insert('contracts', $f);
         redirect "/contracts"
#        redirect "/contract/$contract_id/edit";
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        if (@$p > 0) {
            my $comp = database()->quick_select('contracts',
                                                {id => $id});
            return send_error("Not found", 404) unless ($comp);
            var contract => $comp;
            var contract_id => $id;
            pass
        }

        my $comp = database()->quick_select('contracts_full',
                                            {id => $id});
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
        db()->update('contracts', $f, $id);

        $forms->{contract} =
            database()->quick_select('contracts', {id => $id});
        template 'contract' => { action => "/contract/$id/edit" };
    };

    post '/*/delete' => admin_only sub {
        db()->delete('contracts', vars->{contract_id});
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

=begin comment

prefix '/task' => sub {

    get 's' => sub {
        my @q = database()->quick_select('tasks', {});
        template 'tasks' => { tasks => \@q };
    };

    get 's/add' => admin_only sub {
        delete $forms->{task};
        template 'task' => { action => '/tasks/add' };
    };

    post 's/add' => admin_only sub {
        my $f = to_forms('task')->(qw(name password is_admin));
        # TODO: process errors
        my $task_id = db()->insert('tasks', $f);
        redirect '/tasks';
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        if (@$p > 0) {
            my $task = database()->quick_select('tasks', {id => $id});
            return send_error("Not found", 404) unless ($task);
            var task => $task;
            var task_id => $id;
            return pass
        }
        my $task = database()->quick_select('tasks_full', {id => $id});
        $forms->{task} = $task;
        template 'task' => { action => undef };
    };

    get '/*/edit' => sub {
        my ($id) = splat();
        unless (is_admin() || session('task')->{id} eq $id) {
            return send_error("Not allowed", 403)
        }
        $forms->{task} = vars->{task};
        template 'task' => { action => "/task/$id/edit" };
    };

    post '/*/edit' => sub {
        my $id = vars->{task_id};
        unless (is_admin() || session('task')->{id} eq $id) {
            return send_error("Not allowed", 403)
        }
        my @p = is_admin() ? ('password', 'is_admin', 'company_id') :
                              'password' ;
        my $f = to_forms('task')->(@p);
        db()->update('tasks', $f, $id);

        $forms->{task} =
            database()->quick_select('tasks', {id => $id});
        template 'task' => { action => "/task/$id/edit" };
    };

    post '/*/delete' => admin_only sub {
        db()->delete('tasks', vars->{task_id});
        redirect '/tasks'
    };

};

=cut comment

any '/**' => sub { send_error('not found', 404) };



1;
