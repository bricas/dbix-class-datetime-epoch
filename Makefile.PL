use inc::Module::Install 0.87;

if( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/DBIx/Class/DateTime/Epoch.pm > README' );
}

name 'DBIx-Class-DateTime-Epoch';
all_from 'lib/DBIx/Class/DateTime/Epoch.pm';

requires 'DBIx::Class' => '0.08103'; # InflateColumn::DateTime overriding possible
requires 'DateTime';

test_requires 'Test::More';
test_requires 'DBIx::Class::TimeStamp' => '0.07'; # removes data_type checking
test_requires 'DBICx::TestDatabase';

repository 'http://github.com/bricas/dbix-class-datetime-epoch';

WriteAll;
