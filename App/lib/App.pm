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


sub set_current_form {
    $current_form = $_[0];
    $current_form ? "form_$current_form" : ''
}

sub get_from_current_form {
    if ($current_form) {
        my $cf = $forms->{$current_form};
        return $cf ? $cf->{$_[0]} : ''
    }
    ''
}

sub is_admin { session('user')->{is_admin} }

sub admin_only {
    my $s = shift;
    sub {
        unless (session('user')->{is_admin}) {
            return send_error("Not allowed", 403)
        }
        $s->(@_);
    }
}

hook 'before' => sub {
    if (!session('user') &&
        request->path_info !~ m{^/(logout)|(login)})
    {
        var requested_path => request->path_info;
        request->path_info('/login');
        # FIXME:
        session 'user' => database()->quick_select(
                            'users', {id => session('id')})
    }
};

hook 'before_template' => sub {
    my $t = shift;
    $t->{user} = session('user');
    $t->{session} = \&session;
    $t->{curr_f} = \&set_current_form;
    $t->{f} = \&get_from_current_form;
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
        session(id => $usr->{id});
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
        my @q = database()->quick_select('users', {});
        template 'users' => { users => \@q };
    };

    get 's/add' => admin_only sub {
        delete $forms->{user};
        template 'user' => { action => '/users/add' };
    };

    post 's/add' => admin_only sub {
        my $f = to_forms('user')->(qw(name password is_admin));
        # TODO: process errors
        my $user_id = db()->insert('users', $f);
        redirect '/users';
    };

    any ['get', 'post'] => '/**' => sub {
        my ($p) = splat();
        my $id = shift @{$p};
        my $user = database()->quick_select('users', {id => $id});
        return send_error("Not found", 404) unless ($user);
        var user => $user;
        var user_id => $id;
        pass if @$p > 0;

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
        my @p = is_admin() ? ('password', 'is_admin') : 'password' ;
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

any '/**' => sub { send_error('not found', 404) };

1;
