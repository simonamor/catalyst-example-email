package Sendme::EMKit;

use Email::MIME::Kit;
use Email::Sender::Simple;
use Module::Load;

use strict;
use warnings;

=head1 SYNOPSIS

This module provides functionality to send an email.

    $email = Sendme::EMKit->new({
                transport_class => 'Email::Sender::Transport::Sendmail',
            })
            ->template("welcome", {
                somevar => "a value",
            })
            ->to('"Simon" <simon@example.com>')
            ->from('"No-reply" <no-reply@example.net>')
            ->subject("Welcome to Sendme")
            ->send();

Create a directory (this is the template name) and at a minimum, a file
called manifest.json containing the relevant details. See Email::MIME::Kit
for more information on the manifest.

=head1 METHODS

=head2 new()

Takes an optional hashref containing any of the following:

    transport_class => 'Email::Sender::Transport::Sendmail'
    transport_args => { }

An example of the transport_args would be SMTP details required for
Email::Sender::Transport::SMTP to work.

Returns $self (obviously)

=cut

sub new {
    my $class = shift;
    my $extra_args = @_ && ref($_[0]) eq 'HASH' ? shift : { @_ };

    # Default class doesn't actually send mail
    my $self = {
        transport_class => ($extra_args->{ transport_class } ||
            "Email::Sender::Transport::Test"),

        transport_args  => ($extra_args->{ transport_args } || {}),
        _template_path  => undef,
        _source         => undef,
    };
    # If this isn't defined, things will likely go wrong!
    if (exists $extra_args->{ template_path }) {
        $self->{ _template_path } = $extra_args->{ template_path };
    }

    bless $self, $class;
    return $self;
}

=head2 source

Set/Get the current template source (just a directory name)

Returns $self

=cut

sub source {
    my $self = shift;
    my $template = shift || return $self->{ _source };
    $self->{ _source } = $template;
    return $self;
}

=head2 template( <template_name>, { tmpl_arg => tmpl_value, ... } )

Takes a template name and optional args and generates the required
html/text content from the template(s) and uses the Email::Stuffer
methods html_body and text_body to set the content to send.

=cut

sub template {
    my $self = shift;
    my $template_name = shift or die "template name not provided";
    my $template_args = @_ && ref($_[0]) eq "HASH" ? shift : { @_ };

    $self->source( $template_name );

    # We need to store this since ->to() and ->from() operate on it
    $self->{ _email } = $self->_emkit->assemble( $template_args );

    return $self;
}

=head2 to( <email> )

Set the To header - doesn't fail if no email is provided.

Shortcut for ->header("To", <email>)

Returns $self

=cut

sub to {
    my $self = shift;
    return $self->header("To", shift);
}

=head2 from( <email> )

Set the From header - this will override the default From header provided
by the template. Sets the From header to "" if no <email> is provided.

Shortcut for ->header("From", <email>)

Returns $self

=cut

sub from {
    my $self = shift;
    return $self->header("From", shift);
}

=head2 subject( <subj> )

Set the Subject header - this will override the default Subject header
provided by the template. Blanks the subject if no subject is provided.

Shortcut for ->header("Subject", <subj>)

Return $self

=cut

sub subject {
    my $self = shift;
    return $self->header("Subject", shift);
}

=head2 header( <header>, <string> )

Set the specified <header> to <string>. Can also be used to set the above
headers To/From/Subject if you prefer.

=cut

sub header {
    my $self = shift;
    my $hdr = shift || return $self;
    my $args = shift || "";

    $self->_email->header_str_set( $hdr => $args );
    return $self;
}

=head2 send()

Send the email using the transport_class provided to constructor

=cut

sub send {
    my $self = shift;

    # Loads the correct module
    load $self->{ transport_class };
    my $transport = $self->{ transport_class }->new($self->{ transport_args });
    my $email = $self->_email();
    my %headers = ( $email->header_str_pairs );
    my @recipients = ();
    my $sender = "";
    foreach my $k (keys %headers) {
        push @recipients, $headers{$k} if ($k =~ /^(To|Cc|Bcc)$/i);
        $sender = $headers{$k} if ($k =~ /^From$/i);
    }

    Email::Sender::Simple->send($email, {
        from => $sender,
        to => \@recipients,
        transport => $transport,
    });
    return $self;
}

=head1 INTERNAL METHODS

=head2 _emkit

Get the current Email::MIME::Kit object. If unset, takes either
the source as a parameter ->_emkit("welcome") or will use the
currently defined source as set with ->source("welcome") if
available.

B<WARNING:> Should the kit not exist, this method will die.

Returns Email::MIME::Kit object (and stores it for later use)

=cut

sub _emkit {
    my $self = shift;

    if ($self->{ _emkit }) {
        return $self->{ _emkit };
    }

    my $source = shift || $self->{ _source };
    my $tpath = $self->{ _template_path } || ".";

    die "Cannot create EMKit without a source" unless ($source);

    $self->{ _emkit } = Email::MIME::Kit->new({
        source => "$tpath/emails/$source"
    });

    # If the source kit doesn't exist, the following code will never
    # be run as Email::MIME::Kit dies!
    return $self->{ _emkit };
}

=head2 _email()

B<WARNING:> Does not return $self but returns the assembled email object.
Used internally within ->send(). No validation, returns undef if kit
hasn't been assembled.

Returns Email::MIME object.

=cut

sub _email {
    my $self = shift;
    return $self->{ _email };
}

1;

