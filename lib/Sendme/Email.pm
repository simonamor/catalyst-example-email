package Sendme::Email;

use base 'Email::Stuffer';

use Cwd qw(getcwd);
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

=cut

sub template {
    my $self = shift;
    my $template_name = shift;
    my $template_args = shift;

    unless ($template_name) {
        die "Template name not provided";
    }

    # This is almost certainly not the best way to do it!
    my $class = ref($self);
    $class =~ s{::}{/}g;
    $class .= ".pm";
    my $basepath = $INC{$class};
    if ($basepath !~ m{^/}) {
        $basepath = getcwd . "/" . $basepath;
    }
    my $basedir = $basepath;
    $basedir =~ s{/lib/Sendme/Email.pm}{};

    die "Unable to determine application root" unless $basedir;

    my $template = Template->new({
        render_die => 1,

        INCLUDE_PATH => [
            "$basedir/templates/emails",
            "$basedir/templates/library",
        ],
        CONSTANTS => {
            template_type => 'email',
        }
    }) || die $Template::ERROR, "\n";

    my $template_filename = "$basedir/templates/emails/" . $template_name;

    my $found_templates = 0;

    if (-f "$template_filename.html") {
        my $html_body = "";
        $template->process($template_name . ".html", $template_args, \$html_body)
            or die $template->error;
        $self->html_body($html_body);
        $found_templates ++;
    }

    if (-f "$template_filename.text") {
        my $text_body = "";
        $template->process($template_name . ".text", $template_args, \$text_body)
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

