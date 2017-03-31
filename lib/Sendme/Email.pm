package Sendme::Email;

use base 'Email::Stuffer';

use Template;

use strict;
use warnings;

=head1 SYNOPSIS

Most of the methods are passed through to Email::Stuffer but it also adds
a new method 'template' which generates html_body and text_body from a
pair of templates.

    $email = Sendme::Email->new()
            ->template("welcome")
            ->to('"Simon" <simon@example.com>')
            ->from('"No-reply" <no-reply@example.net>')
            ->subject("Welcome to Sendme")
            ->send();

Create two files in templates/emails/ called welcome.html and welcome.text
These are the plain text and HTML versions of the template. If you need to
omit one or the other, simply don't create the relevant file.

=head1 METHODS

=cut

my $template_path;

=head2 new()

Overrides the Email::Stuffer new() in order to extract the template
path parameter and then passes the rest of the args to Email::Stuffer
even though the args usually don't exist.

=cut

sub new {
    my $class = shift;
    my $extra_args = shift || {};

    if (exists $extra_args->{ template_path }) {
        $template_path = $extra_args->{ template_path };
    }
    return $class->SUPER::new(@_);
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

    my $template = Template->new({
        render_die => 1,

        INCLUDE_PATH => [
            "$template_path/emails",
            "$template_path/library",
        ],
        CONSTANTS => {
            template_type => 'email',
        }
    }) || die $Template::ERROR, "\n";

    my $template_filename = "$template_path/emails/$template_name";

    my $found_templates = 0;

    if (-f "$template_filename.html") {
        my $html_body = "";
        $template->process("$template_name.html", $template_args, \$html_body)
            or die $template->error;
        $self->html_body($html_body);
        $found_templates ++;
    }

    if (-f "$template_filename.text") {
        my $text_body = "";
        $template->process("$template_name.text", $template_args, \$text_body)
            or die $template->error;
        $self->text_body($text_body);
        $found_templates ++;
    }

    if ($found_templates == 0) {
        die "Template $template_name not found";
    }

    return $self;
}

1;

