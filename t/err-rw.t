# errors in sysread/syswrite
use warnings;
use strict;
use t::share;

@CheckPoint = (
    [ 'writer', 0, 'Bad file descriptor'    ], 'writer: Bad file descriptor',
    [ 'writer', 0, 'Broken pipe'            ], 'writer: Broken pipe',
    [ 'reader', 0, 'Bad file descriptor'    ], 'reader: Bad file descriptor',
);
plan tests => @CheckPoint/2;

pipe my $rd_pipe, my $wr_pipe or die "pipe: $!";

my $timeout = $INC{'Devel/Cover.pm'} ? 2 : 0.5;
my $t = EV::timer $timeout, 0, sub {
    my $r = EV::Stream->new({
        fh          => $rd_pipe,
        cb          => \&reader,
        wait_for    => 0,
    });
    close $rd_pipe;
};

my $w = EV::Stream->new({
    fh          => $wr_pipe,
    cb          => \&writer,
    wait_for    => 0,
});
$w->write('x' x 204800);

EV::loop;


sub writer {
    my ($io, $e, $err) = @_;
    checkpoint($e, $err);
}
sub reader {
    my ($io, $e, $err) = @_;
    checkpoint($e, $err);
    EV::unloop;
}
