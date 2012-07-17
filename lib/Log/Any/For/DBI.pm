package Log::Any::For::DBI;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

our $VERSION = '0.05'; # VERSION

use DBI;
use Log::Any::For::Class qw(add_logging_to_class);
use Scalar::Util qw(blessed);

sub import {
    my $logger = sub {
        my ($which, $args) = @_;
        my $name = $args->{name};

        if ($which eq 'precall') {
            my $margs = $args->{args};

            # exclude self or package
            shift @$margs;

            # mask connect password
            if ($name =~ /\A(DBI::connect\w*)\z/) {
                $margs->[2] = "********";
            }

            $log->tracef("---> %s(%s)", $name, $margs);
        } else {
            if (@{$args->{result}}) {
                $log->tracef("<--- %s() = %s", $name, $args->{result});
            } else {
                $log->tracef("<--- %s()", $name);
            }
        }
    };

    # I put it in $doit in case we need to add more classes from inside $logger,
    # e.g. DBD::*, etc.
    my $doit;
    $doit = sub {
        my @classes = @_;

        add_logging_to_class(
            classes => \@classes,
            precall_logger => sub { $logger->('precall', shift) },
            postcall_logger => sub { $logger->('postcall', shift) },
            filter_methods =>
                qr/\A(
                       DBI::(connect|connect_cached)|
                       DBI::db::(do|prepare|select\w+)|
                       DBI::st::(execute|bind\w+)
                   )\z/x,
        );
    };

    $doit->("DBI", "DBI::db", "DBI::st");
}

1;
# ABSTRACT: Add logging to DBI method calls, etc


__END__
=pod

=head1 NAME

Log::Any::For::DBI - Add logging to DBI method calls, etc

=head1 VERSION

version 0.05

=head1 SYNOPSIS

 use DBI;
 use Log::Any::For::DBI;

 # now all connect()'s, do()'s, prepare()'s are logged with Log::Any
 my $dbh = DBI->connect("dbi:...", $user, $pass);
 $dbh->do("INSERT INTO table VALUES (...)");

Sample script and output:

 % TRACE=1 perl -MLog::Any::App -MDBI -MLog::Any::For::DBI \
   -e'$dbh=DBI->connect("dbi:SQLite:dbname=/tmp/tmp.db", "", "");
   $dbh->do("CREATE TABLE IF NOT EXISTS t (i INTEGER)");'
 [1] ---> DBI::connect(['dbi:SQLite:dbname=/tmp/tmp.db','','********'])
 [5] <--- DBI::connect() = [bless( {}, 'DBI::db' )]
 [5] ---> DBI::db::do(['CREATE TABLE IF NOT EXISTS t (i INTEGER)'])
 [5] ---> DBI::db::prepare(['CREATE TABLE IF NOT EXISTS t (i INTEGER)',undef])
 [5] <--- DBI::db::prepare() = [bless( {}, 'DBI::st' )]
 [5] ---> DBI::st::execute([])
 [5] <--- DBI::st::execute() = ['0E0']
 [5] <--- DBI::db::do()

=head1 SEE ALSO

L<Log::Any::For::Class>

L<DBIx::Log4perl>, one of the inspirations for this module. With due respect to
its author, I didn't like the approach of DBIx::Log4perl and its intricate links
to DBI's internals. I'm sure DBIx::Log4perl is good at what it does, but
currently I only need to log SQL statements.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

