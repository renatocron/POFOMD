use strict;
use warnings;

use POFOMD;

my $app = POFOMD->apply_default_middlewares(POFOMD->psgi_app);
$app;

