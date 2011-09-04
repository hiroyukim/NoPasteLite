package NoPasteLite;
use strict;
use warnings;
use base qw/Class::Data::Inheritable Class::Accessor::Fast/;
our $VERSION = '0.01';
use Router::Simple;
use FindBin;
use NoPasteLite::Request;
use Class::Load;


__PACKAGE__->mk_accessors(qw/req stash/);
__PACKAGE__->mk_classdata($_) for qw(config router request_class);
__PACKAGE__->request_class('NoPasteLite::Request');

__PACKAGE__->config(+{
    router => [
        { path => '/',     info => { controller => 'Root', action => 'index' } },
        { path => '/show', info => { controller => 'Root', action => 'show'  } },
    ]
});

my $ROUTER;
__PACKAGE__->router(
    $ROUTER || do {
        $ROUTER = Router::Simple->new(); 

        for my $row ( @{__PACKAGE__->config->{router}} ) {
            $ROUTER->connect($row->{path},$row->{info});
        }

        $ROUTER;
    }
);

sub new {
    my ($class,$env) = @_;

    my $self = bless {
        req   => $class->request_class->new($env,'utf8'),
        stash => {},
    },$class;
}

sub run {
    my $self = shift;

    if( my $p = $self->router->match($env) ) {
        my $controller = 'NoPasteLie::Controller::' . $p->{info}->{controller}; 
        Class::Load::load_class($controller);            

        my $method = 'dispatch_' . $p->{info}->{action};
        $controller->new->$method($self);

        return $self->render();
    }
    else {
        return [404,[],['not found']];
    }
}

1;
__END__

