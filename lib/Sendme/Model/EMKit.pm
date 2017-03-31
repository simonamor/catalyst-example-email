package Sendme::Model::EMKit;

use strict;
use warnings;

use base 'Catalyst::Model::Factory';

use Sendme::EMKit;
use Moose;

=head1 NAME

Sendme::Model::EMKit

=head1 DESCRIPTION

This module provides a way to access Sendme::EMKit and send emails

=head1 METHODS

=cut

our $AUTOLOAD;

has 'EmailInstance' => (
    is => 'rw',
    isa => 'Sendme::EMKit',
);

__PACKAGE__->config( class => "Sendme::Model::EMKit" );

=head2 ACCEPT_CONTEXT

This ensures that any requests for $c->model('EMKit') return a fresh
object that hasn't already been referenced.

=cut

# One instance per $c->model() request
sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    return Sendme::EMKit->new(
        { template_path => $c->path_to('templates')->stringify },
        @args );
}

sub AUTOLOAD {
    my $self = shift;
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    $self->EmailInstance->$name(@_);
}

1;

