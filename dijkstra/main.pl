package RPN;
use warnings;
use strict;
use v5.10;

sub new { my $s = []; bless($s, shift); $s }

sub compute {
    my $self = shift;
    my @s;
    for my $tok (@{$self}) {
        given ($tok) {
            when ('*') { push @s, (pop @s) * pop @s }
            when ('/') { ($a, $b) = (pop @s, pop @s); push @s, $b / $a }
            when ('-') { ($a, $b) = (pop @s, pop @s); push @s, $b - $a }
            when ('+') { push @s, (pop @s) + pop @s }
            when ('^') { $a = pop @s; $b = pop @s; push @s, $b ** $a }
            when ('p') { }
            when ('m') { $s[-1] = -$s[-1] }
            default { push @s, $tok }
        }
    }
    die unless int @s == 1;
    $s[0]
}

sub print {
    my $s = shift;
    print join ' ', @$s
}

1;

package Node;
use warnings;
use strict;

sub new {
    my $s = {}; bless($s, shift);
    $s->{data} = $_[0] if defined $_[0];
    $s->{left} = $_[1] if defined $_[1];
    $s->{right} = $_[2] if defined $_[2];
    $s
}

sub _access_fielf {
    my $s = shift;
    my $field = shift;
    $_[0] ? $s->{$field} = $_[0] : $s->{$field}
}

sub left { shift->_access_fielf('left', @_) }
sub right { shift->_access_fielf('right', @_) }
sub data { shift->_access_fielf('data', @_) }

sub print {
    my ($s, $offset) = @_;
    $offset //= 0;
    print( ('  ' x $offset), $s->{data}, "\n" );
    $s->{left}->print($offset + 1) if $s->{left};
    $s->{right}->print($offset + 1) if $s->{right};
}

sub to_rpn {
    my $s = shift;
    $_[0] //= RPN->new();
    $s->{left}->to_rpn($_[0]) if $s->{left};
    $s->{right}->to_rpn($_[0]) if $s->{right};
    if ($s->{data} ~~ [qw(+ -)] && !defined $s->{right}) {
        push @{$_[0]}, ($s->{data} eq '+' ? 'p' : 'm');
    } else {
        push @{$_[0]}, $s->{data};
    }
    $_[0];
}

1;

package Dijkstra;
use warnings;
use strict;
use v5.10;

sub new {
    my $s = {};
    bless($s, shift);
    $s->{tokens} = shift;
    $s->{last_tok} = '';
    $s
}

sub get_priority {
    given ($_[1]) {
        when ('(') { return 1 }
        when (')') { return 0 }
        when (['+', '-']) { return 2 }
        when (['*', '/']) { return 3 }
        when ('^') { return 4 }
        when (['m', 'p']) { return 5 }
    }
}

sub tok_is_left_assoc { !($_[1] ~~ ["p","m","^"]) }

sub parse {
    my $s = shift;
    my $res = RPN->new();
    my $tok = $s->next_token();
    my $last_tok;
    my @stack;

    my $dump = sub {
        print "tok: ", $tok, "\n";
        print "stack: ", join ' ', @stack, "\n";
        print "res: ", join '', @$res, "\n";
    };

    while ($tok) {
        if ($tok =~ /\d/) {
            push @$res, $tok;
        } elsif ($tok eq '(') {
            push @stack, $tok
        } elsif ($tok eq ')') {
            while (@stack && $stack[-1] ne '(') {
                push @$res, pop @stack;
            }
            $s->assert($stack[-1] eq '(', 'unmatched ")"');
            pop @stack;
        } else {
            while (@stack &&
                   $s->get_priority($stack[-1]) > $s->get_priority($tok))
            {
                push @$res, pop @stack;
            }
            if ($s->tok_is_left_assoc($tok) &&
                @stack && $stack[-1] eq $tok)
            {
                push @$res, pop @stack;
            }
            push @stack, $tok
        }
        $last_tok = $tok;
        $tok = $s->next_token();
    }
    while (@stack) { push @$res, pop @stack }
    $res
}


sub next_token {
    my $s = shift;
    my $t = shift @{$s->{tokens}} // '';
    my $res;
    if ($t ~~ [qw(+ -)] &&
        $s->{last_tok} ~~ ['', '+', '-', '(', '*', '/'] )
    {
        $res = $t eq '+' ? 'p' : 'm'
    } else {
        $res = $t
    }
    $s->{last_tok} = $t;
    $res
}

sub look_next_token { shift->{tokens}[0] // '' }

sub assert {
    my $s = shift;
    die $_[1] unless $_[0]
}

1;

package RecursiveDescent;
use warnings;
use strict;

sub new {
    my $s = {}; bless($s, shift);
    $s->{tokens} = shift;
    $s
}

sub _parse_binary {
    my ($s, $allowed_op, $next_parse) = @_;
    my $a = $s->$next_parse();
    my $op = $s->look_next_token();
    while ($op && $op ~~ $allowed_op) {
        $s->next_token();
        my $b = $s->$next_parse();
        $s->assert($b, 'unexpected end of input');
        $a = Node->new($op, $a, $b);
        $op = $s->look_next_token();
    }
    $a
}

sub _parse_expr0 {
    my $s = shift;
    my $tok = $s->next_token();
    if ($tok eq '(') {
        my $res = $s->_parse_expr3();
        $s->assert($s->next_token() eq ')', '")" expected');
        return $res
    }
    if ($tok ~~ [qw(- +)]) {
        return Node->new($tok, $s->_parse_expr0())
    }
    $s->assert($tok =~ /\d/, 'number expected');
    Node->new($tok)
}

sub _parse_expr1 {
    my $s = shift;
    my $a = $s->_parse_expr0();
    my $op = $s->look_next_token();
    while ($op && $op eq '^') {
        $s->next_token();
        my $b = $s->_parse_expr1();
        $s->assert($b, 'unexpected end of input');
        $a = Node->new($op, $a, $b);
        $op = $s->look_next_token();
    }
    $a
}

sub _parse_expr2 {
    shift->_parse_binary([qw(* /)], '_parse_expr1');
}

sub _parse_expr3 {
    shift->_parse_binary([qw(+ -)], '_parse_expr2');
}

sub next_token {
    my $s = shift;
    shift @{$s->{tokens}} // ''
}

sub look_next_token { shift->{tokens}[0] // '' }

sub parse {
    my ($s, $tokens) = @_;
    $s->_parse_expr3()
}

sub assert {
    my $s = shift;
    die $_[1] unless $_[0]
}

1;

package Scaner;
use warnings;
use strict;
use v5.10;

sub new { my $s = {}; bless($s, shift); $s }

sub tokenize {
    my $s = shift;
    my @res;
    my $buff;
    my $state = 'space';
    my $flush = sub {
        push @res, $buff if $buff;
        $buff = '';
        $state = 'space';
    };
    for my $sym (@_) {
        given($sym) {
            when (/\s/) { $flush->() }
            when (/\d/) {
                $flush->() if $state ne 'num' && $state ne 'float';
                $buff .= $_;
                $state = 'num';
            }
            when ('.') {
                die 'unexpected "."' if $state ne 'num';
                $buff .= $_;
                $state = 'float';
            }
            when ([qw| ( ) + - * / ^|]) {
                $flush->();
                $buff = $_;
                $flush->();
            }
            default {
                die 'unexpected character: ' . $_
            }
        }
    }
    \@res
}

sub split {
    my ($s, $file_h) = @_;
    my $res = [];
    while (my $line = <$file_h>) {
        push @$res, $_ for @{$s->tokenize(split //, $line)};
    }
    $res
}

1;

package main;
use warnings;
use strict;
use v5.10;

use Data::Dumper;

use Carp;
$SIG{__WARN__} = sub { Carp::confess @_ };
$SIG{__DIE__} = sub { Carp::confess @_ };
$SIG{INT} = sub { Carp::confess @_ };

sub compute_recursive_descent {
    open my $f, '<', shift;
    my $lex = Scaner->new()->split($f);
    my $tree = RecursiveDescent->new($lex)->parse();
    my $rpn = $tree->to_rpn();
    my $res = $rpn->compute();
    close $f;
    $res;
}

sub compute_dijkstra {
    open my $f, '<', shift;
    my $lex = Scaner->new()->split($f);
    my $rpn = Dijkstra->new($lex)->parse();
    my $res = $rpn->compute();
    close $f;
    $res
}

my $f = shift || 'tmp.txt';
my $res = compute_dijkstra($f);
my $res2 = compute_recursive_descent($f);
die if $res ne $res2;

print $res;

1;
