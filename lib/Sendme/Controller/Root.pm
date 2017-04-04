package Sendme::Controller::Root;
use Moose;
use namespace::autoclean;

use Email::MIME::Kit;
use HTML::Entities;

use Email::Sender::Simple;
use Email::Sender::Transport::Sendmail;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in Sendme.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

Sendme::Controller::Root - Root Controller for Sendme

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        template => "form.html",
        form_action => "/",
    );

    if (my $email = $c->request->params->{ email }) {
        my $name = $c->request->params->{ name } || "anonymous";

        # Send a test email
        my $kit = Email::MIME::Kit->new(
            source => $c->path_to('templates', 'emails', 'msg1.mkit'),
        );
        my $msg = $kit->assemble({
            yourname => $name,
            destination_email => $email,
        });

        my $transport = $c->config->{ email_transport }->new();
        Email::Sender::Simple->send($msg, {
            to => $email,
            transport => $transport,
        });

        $c->stash(
            message => HTML::Entities::encode_entities($msg->as_string)
        );
    }
}

=head2 sendemail

Sending via model('Email') (/sendemail)

=cut

sub sendemail :Path("sendemail") :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        template => "form.html",
        form_action => "/sendemail",
    );

    if (my $email = $c->request->params->{ email }) {
        my $name = $c->request->params->{ name } || "anonymous";

        # Send a test email
        my $email = $c->model('Email')
            ->template( "welcome", {
                yourname => $name,
                destination_email => $email,
            })
            ->to( $email )
            ->from( '"Simon" <simon@example.com>' )
            ->header('Reply-To', '"Simon" <simon@example.net>')
            ->subject( "Test form submission via Email" );
        $email->send();

        $c->stash(
            message => HTML::Entities::encode_entities($email->as_string)
        );
    }
}

=head2 sendemkit

Sending via model('EMKit') (/sendemkit)

=cut

sub sendemkit :Path("sendemkit") :Args(0) {
    my ($self, $c) = @_;

    $c->stash(
        template => "form.html",
        form_action => "/sendemkit",
    );

    if (my $email = $c->request->params->{ email }) {
        my $name = $c->request->params->{ name } || "anonymous";

        # Send a test email
        my $emkit = $c->model('EMKit',
                transport_class => 'Email::Sender::Transport::Sendmail',
            )
            ->template( "msg1.mkit", {
                yourname => $name,
                destination_email => $email,
            })
            ->to( $email )
            ->from( '"Simon" <simon@example.com>' )
            ->header('Reply-To', '"Simon" <simon@example.net>')
            ->subject( "Test form submission via EMKit" );

        $c->log->debug( "Email:\n" . $emkit->_email->as_string );

        $emkit->send();

        $c->stash(
            message => HTML::Entities::encode_entities($emkit->_email->as_string)
        );
    }
}


=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
