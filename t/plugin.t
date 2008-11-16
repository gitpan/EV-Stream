# No-op plugins in action.
use warnings;
use strict;
use t::share;
use EV::Stream::Noop;
use EV::Stream::NoopAlias;


@CheckPoint = (
    [ 'EVENT', RESOLVED, undef          ], 'EventLog::EVENT(RESOLVED)',
    [ 'WRITE'                           ], 'EventLog::WRITE',
    [ 'EVENT', CONNECTED|OUT|SENT, undef], 'EventLog::EVENT(CONNECTED|OUT|SENT)',
    [ 'client', SENT                    ], 'client: SENT',
    [ 'server', EOF                     ], 'server: EOF',
    [ 'server', 'test'                  ], '  got "test"',
    [ 'server', SENT                    ], 'server: SENT',
    [ 'EVENT', IN, undef                ], 'EventLog::EVENT(IN)',
    [ 'EVENT', EOF, undef               ], 'EventLog::EVENT(EOF)',
    [ 'client', EOF                     ], 'client: EOF',
    [ 'client', 'echo: test'            ], '  got "echo: test"',
);
plan tests => 3 + @CheckPoint/2;


my $srv_sock = tcp_server('127.0.0.1', 4444);
my $srv_w = EV::io($srv_sock, EV::READ, sub {
    if (accept my $sock, $srv_sock) {
        EV::Stream->new({
            fh          => $sock,
            cb          => \&server,
            wait_for    => EOF,
            in_buf_limit=> 1024,
        });
    }
    elsif ($! != EAGAIN) {
        die "accept: $!\n";
    }
});

my $io = EV::Stream->new({
    host        => '127.0.0.1',
    port        => 4444,
    cb          => \&client,
    wait_for    => SENT,
    in_buf_limit=> 1024,
    out_buf     => 'test',
    plugin      => [
        noop        => EV::Stream::Noop->new(),
        eventlog    => EV::Stream::EventLog->new(),
        noopalias   => EV::Stream::NoopAlias->new(),
    ],
});

is(ref $io->{plugin}{noop}, 'EV::Stream::Noop',
    '{plugin}{noop} available');
is(ref $io->{plugin}{eventlog}, 'EV::Stream::EventLog',
    '{plugin}{eventlog} available');
is(ref $io->{plugin}{noopalias}, 'EV::Stream::NoopAlias',
    '{plugin}{noopalias} available');

EV::loop;


sub server {
    my ($io, $e, $err) = @_;
    die $err if $err;
    checkpoint($e);
    if ($e & EOF) {
        checkpoint($io->{in_buf});
        $io->{wait_for} = SENT;
        $io->write("echo: $io->{in_buf}");
    }
    if ($e & SENT) {
        $io->close();
    }
}

sub client {
    my ($io, $e, $err) = @_;
    die $err if $err;
    checkpoint($e);
    if ($e & SENT) {
        $io->{wait_for} = EOF;
        shutdown $io->{fh}, 1;
    }
    if ($e & EOF) {
        checkpoint($io->{in_buf});
        $io->close();
        EV::unloop();
    }
}


package EV::Stream::EventLog;
use base 'EV::Stream::NoopAlias';
sub WRITE {
    main::checkpoint();
    shift->SUPER::WRITE(@_);
}
sub EVENT {
    main::checkpoint($_[1], $_[2]);
    shift->SUPER::EVENT(@_);
}

