package EV::Stream::const;

use warnings;
use strict;

use version; our $VERSION = qv('0.1.0');

# update DEPENDENCIES in POD & Makefile.PL & README
use Scalar::Util qw( dualvar );
use Errno qw( EAGAIN );
use Fcntl ();
use Socket ();


use constant BUFSIZE => 8192;

# Events:
use constant RESOLVED       => 1<<0;
use constant CONNECTED      => 1<<1;
use constant IN             => 1<<2;
use constant OUT            => 1<<3;
use constant EOF            => 1<<4;
use constant SENT           => 1<<5;

# Timeouts:
use constant TOCONNECT      => 30;
use constant TOWRITE        => 30;

# Custom errors:
use constant EINBUFLIMIT    => dualvar(-100, 'in_buf_limit reached');
use constant ETORESOLVE     => dualvar(-101, 'dns timeout');
use constant ETOCONNECT     => dualvar(-102, 'connect timeout');
use constant ETOWRITE       => dualvar(-103, 'write timeout');
use constant EDNS           => dualvar(-200, 'dns error');
use constant EDNSNXDOMAIN   => dualvar(-201, 'dns nxdomain');
use constant EDNSNODATA     => dualvar(-202, 'dns nodata');
use constant EREQINBUFLIMIT => dualvar(-300, 'in_buf_limit required');
use constant EREQINEOF      => dualvar(-301, 'IN or EOF required in wait_for');

# Cache for speed:
use constant F_SETFL        => Fcntl::F_SETFL();
use constant O_NONBLOCK     => Fcntl::O_NONBLOCK();
use constant PROTO_TCP      => scalar getprotobyname 'tcp';
use constant AF_INET        => Socket::AF_INET();
use constant SOCK_STREAM    => Socket::SOCK_STREAM();


sub import {
    my $pkg = caller;
    no strict 'refs';
    for my $const (qw(

            BUFSIZE

            EAGAIN

            RESOLVED CONNECTED IN OUT EOF SENT

            TOCONNECT TOWRITE

            EINBUFLIMIT ETORESOLVE ETOCONNECT ETOWRITE
            EDNS EDNSNXDOMAIN EDNSNODATA 
            EREQINBUFLIMIT EREQINEOF

            F_SETFL O_NONBLOCK PROTO_TCP AF_INET SOCK_STREAM

            )) {
        *{"${pkg}::$const"} = \&{$const};
    }
    return;
}


1;
