package Sendme::Model::Email;

use strict;
use warnings;

use base 'Catalyst::Model::Factory';

use Sendme::Email;
use Moose;

=head1 NAME

Sendme::Model::Email

=head1 DESCRIPTION

This module provides a way to access Sendme::Email and send emails

=head1 METHODS

=cut

our $AUTOLOAD;

has 'EmailInstance' => (
    is => 'rw',
    isa => 'Sendme::Email',
);

__PACKAGE__->config( class => "Sendme::Model::Email" );

=head2 ACCEPT_CONTEXT

This ensures that any requests for $c->model('Email') return a fresh
object that hasn't already been referenced.

=cut

# One instance per $c->model() request
sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    return Sendme::Email->new(
        { template_path => $c->path_to('templates')->stringify },
        @args );
}

sub AUTOLOAD {
    my $self = shift;
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    $self->EmailInstance->$name(@_);
}

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
