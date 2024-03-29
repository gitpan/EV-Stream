# Write timeout.
use warnings;
use strict;
use EV::Stream::const ();
BEGIN {
    *EV::Stream::const::TOWRITE     = sub () { 0.1 };
}
use t::share;


@CheckPoint = (
    [ 'client',     RESOLVED, undef        ], 'client: RESOLVED',
    [ 'client',     CONNECTED, undef       ], 'client: CONNECTED',
    [ 'client',     0, 'write timeout'     ], 'client: write timeout',
);
plan tests => @CheckPoint/2;



my $srv_sock = tcp_server('127.0.0.1', 4444);
EV::Stream->new({
    host        => '127.0.0.1',
    port        => 4444,
    cb          => \&client,
    wait_for    => RESOLVED|CONNECTED|SENT,
    out_buf     => ('x' x 2048000),
});

EV::loop;


sub client {
    my ($io, $e, $err) = @_;
    checkpoint($e, $err);
    EV::unloop if $err;
}

