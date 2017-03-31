package Sendme::EMKit;

use Email::MIME::Kit;

use strict;
use warnings;

=head1 SYNOPSIS

This offers similar methods to Email::Stuffer

    $email = Sendme::EMKit->new()
            ->template("welcome")
            ->to('"Simon" <simon@example.com>')
            ->from('"No-reply" <no-reply@example.net>')
            ->subject("Welcome to Sendme")
            ->send();

Create two files in templates/emails/ called welcome.html and welcome.text
These are the plain text and HTML versions of the template. If you need to
omit one or the other, simply don't create the relevant file.

=head1 METHODS

=head2 new()

=cut

sub new {
    my $class = shift;
    my $extra_args = shift || {};

    # Default class doesn't actually send mail
    my $self = {
        transport_class => ($extra_args->{ transport_class } ||
            "Email::Sender::Transport::Test"),

        transport_args => ($extra_args->{ transport_args } || undef),
    };
    # If this isn't defined, things will likely go wrong!
    if (exists $extra_args->{ template_path }) {
        $self->{ template_path } = $extra_args->{ template_path };
    }

    bless $self, $class;
    return $self;
}

=head2 template()

Takes a template name and optional args and generates the required
html/text content from the template(s) and uses the Email::Stuffer
methods html_body and text_body to set the content to send.

=cut

sub template {
    my $self = shift;
    my $template_name = shift or die "template name not provided";
    my $template_args = shift;

    $self->{ emkit } = Email::MIME::Kit->new({
        source => "$self->{ template_path }/emails/$template_name",
    });
    my $email = $self->{ emkit }->assemble($template_args);
    return $email;
}

sub send {
    my $self = shift;

    my $transport = $self->{ transport_class }->new($self->{ transport_args });

    my $email = $self->{ email };

    Email::Sender::Simple->send($email, {
        to => $email,
        transport => $transport,
    });

    return $self;
}

1;

