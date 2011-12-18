package App::Database;
use warnings;
use strict;

use Dancer ':syntax';
use Dancer::Plugin::Database;

use Exporter::Easy ( EXPORT => ['db'] );


use Data::Dumper::Concise;


sub db { __PACKAGE__ };

sub last_err { return $DBI::errstr }

sub insert {
    my ($s, $table, $h) = @_;
    my (@k, @v);
    while (my ($k, $v) = each $h) {
        push @k, $k;
        push @v, $v;
    }
    my $q =
        'insert into ' . $table . ' (' . (join ', ', @k) . ') ' .
        'values (' . (join ', ', ('?') x @k) . ') returning id';
    my $sth = database->prepare($q);
    debug( "********** SQL **********:  ", $q, "\n",
           {args => \@v}, "\n" );
    my $res = $sth->execute(@v) or return undef;
    $sth->fetchrow_hashref()->{id}
}

sub update {
    my ($s, $table, $h, $id) = @_;
    my @expr;
    my @v;
    while (my ($k, $v) = each $h) {
        push @expr, "$k = ?";
        push @v, $v;
    }
    my $q =
        'update ' . $table . ' set ' . (join ', ', @expr) .
        ' where id = ? returning *';
    my $sth = database()->prepare($q);
    debug( "********** SQL **********:  ", $q, "\n",
           {id => $id, args => \@v}, "\n" );
    $sth->execute(@v, $id);
    $sth->fetchrow_hashref();
}

sub delete {
    my ($s, $table, $id) = @_;
    my $q =
        'delete from ' . $table . ' where id = ?';
    debug( "********** SQL **********:  ", $q, "\n",
           {id => $id}, "\n" );
    my $sth = database()->prepare($q);
    $sth->execute($id);
}

1;
