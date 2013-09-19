use Test::More;
use Test::Exception;
use Elasticsearch;
use lib 't/lib';
use Elasticsearch::MockCxn qw(mock_sniff_client);

## Runaway nodes (ie wrong HTTP response codes signal node failure, instead of
## request failure)

my $t = mock_sniff_client(
    { nodes => [ 'one', 'two' ] },

    { node => 1, sniff => [ 'one', 'two' ] },
    { node => 2, code  => 200,     content => 1 },
    { node => 3, code  => 503,     error   => 'NotReady' },
    { node => 2, sniff => [ 'one', 'two' ] },
    { node => 4, code  => 503,     error   => 'NotReady' },

    # throw Internal: too many retries

    { node => 5, sniff => [ 'one', 'two' ] },
    { node => 6, code  => 503,     error => 'NotReady' },
    { node => 7, sniff => [ 'one', 'two' ] },
    { node => 8, code  => 503,     error => 'NotReady' },

    # throw Internal: too many retries
);

ok $t->perform_request
    && !eval { $t->perform_request }
    && $@ =~ /Retried request/
    && !eval { $t->perform_request }
    && $@ =~ /Retried request/,
    "Runaway nodes";

done_testing;