use warnings;
use strict;
use Test::More;

use EV::Stream qw(:Error);

my @exports = qw(
        EINBUFLIMIT
        ETORESOLVE ETOCONNECT ETOWRITE
        EDNS EDNSNXDOMAIN EDNSNODATA
    );
my @not_exports = qw(
        RESOLVED CONNECTED IN EOF OUT SENT
        BUFSIZE
        TOCONNECT TOWRITE
        EREQINBUFLIMIT EREQINEOF
    );

plan +(@exports + @not_exports)
    ? ( tests       => @exports + @not_exports                  )
    : ( skip_all    => q{This module doesn't export anything}   )
    ;

for my $export (@exports) {
    can_ok( __PACKAGE__, $export );
}

for my $not_export (@not_exports) {
    ok( ! __PACKAGE__->can($not_export) );
}
