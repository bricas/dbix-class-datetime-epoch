use inc::Module::Install 0.67;

if( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/DBIx/Class/DateTime/Epoch.pm > README' );
}

name 'DBIx-Class-DateTime-Epoch';
all_from 'lib/DBIx/Class/DateTime/Epoch.pm';

requires 'DBIx::Class';
requires 'DateTime';

test_requires 'Test::More';

auto_install;
WriteAll;
