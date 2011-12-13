package App;
use Dancer ':syntax';
use Dancer::Plugin::Database;

use Data::Dumper::Concise;

our $VERSION = '0.1';

hook 'before' => sub {
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
    my ($n, $p) = map { param($_) } qw(name password);
    my $usr = database()->quick_select('users',
                          { name => $n, password => $p});
    my ($err, $msg);
    unless ($usr) {
        $err = 'wrong user name or password';
        session()->destroy();
    } else {
        session(user => $usr);
        if (vars->{requested_path}) {
            return forward( vars->{requested_path} )
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

prefix '/users' => sub {

    get '/' => sub {
        my @q = database()->quick_select('users', {});
        template 'users' => { users => \@q };
    };

    get '/add' => sub {

    };

    get '/edit/*' => sub {
        my ($user) = splat();
        return $user;
    };
    post '/edit/*' => sub {
        my ($user) = splat();
        return $user;
    }
};

1;
