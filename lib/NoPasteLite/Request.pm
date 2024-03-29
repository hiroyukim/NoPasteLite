package NoPasteLite::Request;
use strict;
use warnings;
use base 'Plack::Request';
use Carp ();
use Encode;
use Hash::MultiValue;

sub new {
    my($class, $env, $encoding) = @_;

    Carp::croak(q{$env is required})
        unless defined $env && ref($env) eq 'HASH';
    Carp::croak(q{$encoding is required})
        unless defined $encoding;

    bless { 
        env      => $env, 
        encoding => $encoding,
    }, $class;
}

# copy form amon2
sub body_parameters {
    my ($self) = @_;
    $self->{'plack.body_parameters'} ||= $self->_decode_parameters($self->SUPER::body_parameters());
}

sub query_parameters {
    my ($self) = @_;
    $self->{'plack.query_parameters'} ||= $self->_decode_parameters($self->SUPER::query_parameters());
}

sub _decode_parameters {
    my ($self, $stuff) = @_;

    my $encoding = $self->{encoding};
    my @flatten  = $stuff->flatten();
    my @decoded;
    while ( my ($k, $v) = splice @flatten, 0, 2 ) {
        push @decoded, Encode::decode($encoding, $k), Encode::decode($encoding, $v);
    }
    return Hash::MultiValue->new(@decoded);
}
sub parameters {
    my $self = shift;

    $self->env->{'plack.request.merged'} ||= do {
        my $query = $self->query_parameters;
        my $body  = $self->body_parameters;
        Hash::MultiValue->new( $query->flatten, $body->flatten );
    }
}

1;
