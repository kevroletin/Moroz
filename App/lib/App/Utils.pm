package App::Utils;
use warnings;
use strict;

use Exporter::Easy ( EXPORT => ['even_odd'] );

sub even_odd {
    ['even', 'odd']->[$_[0] % 2]
}

1;
