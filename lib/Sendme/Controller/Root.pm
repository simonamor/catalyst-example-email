package Sendme::Controller::Root;
use Moose;
use namespace::autoclean;

use Email::MIME::Kit;
use HTML::Entities;

use Email::Sender::Simple;
use Email::Sender::Transport::Test;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
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

    my $html = <<EOF;
<p>Enter your email address and click Send</p>

<form method="POST" action="/">
<input type="text" name="email" value="">
<input type="submit" value="Send!">
</form>
EOF

    if (my $email = $c->request->params->{ email }) {

        my $name = $c->request->params->{ name } || "anonymous";

        # Send a test email

        my $kit = Email::MIME::Kit->new(
            source => $c->path_to('email', 'msg1.mkit'),
        );
        my $msg = $kit->assemble({
            yourname => $name,
        });

        my $transport = $c->config->{ email_transport }->new();
        Email::Sender::Simple->send($msg, {
            to => $email,
            transport => $transport,
        });

        $html = "<pre>" . HTML::Entities::encode_entities($msg->as_string) . "</pre>";
    }
    $c->response->body($html);
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

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
