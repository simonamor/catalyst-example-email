use strict;
use warnings;

use Sendme;

my $app = Sendme->apply_default_middlewares(Sendme->psgi_app);
$app;

