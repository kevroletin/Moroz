package App::Utils;
use warnings;
use strict;

use Exporter::Easy ( EXPORT => ['even_odd'] );

sub even_odd {
    ['even', 'odd']->[$_[0] % 2]
}

#sub log_sql {
#     print STDERR "**********SQL: " . $_[0] || '' . "\n";
#     print "<pre>$_[0]</pre>";
#     $_[0]
#}


1;
