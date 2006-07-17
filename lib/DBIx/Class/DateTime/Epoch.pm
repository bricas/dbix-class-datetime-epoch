package DBIx::Class::DateTime::Epoch;

use strict;
use warnings;

our $VERSION = '0.02';

use base qw( DBIx::Class );

use DateTime;

=head1 NAME

DBIx::Class::DateTime::Epoch - Automatic inflation/deflation of epoch-based DateTime objects for DBIx::Class

=head1 SYNOPSIS

    package foo;
    
    use base qw( DBIx::Class );
    
    __PACKAGE__->load_components( qw( DateTime::Epoch Core ) );
    __PACKAGE__->add_columns(
        name => {
            data_type => 'varchar',
            size      => 10
        },
        bar => {
            data_type => 'bigint',
            epoch     => 1
        },
        creation_time => {
            data_type => 'bigint',
            epoch     => 'ctime'
        },
        modification_time => {
            data_type => 'bigint',
            epoch     => 'mtime'
        }
    );

=head1 DESCRIPTION

This module automatically inflates/deflates DateTime objects
corresponding to applicable columns. Columns may also be
defined to specify their nature, such as columns representing a
creation time (set at time of insertion) or a modification time
(set at time of every update).

=head1 METHODS

=head2 register_column

This method will automatically add inflation and deflation rules
to a column if an epoch value has been set in the column's definition.
If the epoch value is 'ctime' (creation time) or 'mtime'
(modification time), it will be registered as such for later
use by the insert and the update methods.

=head2 insert

This method will set the value of all registered creation time
columns to the current time. No changes will be made to a column
whose value has already been set.

=head2 update

This method will set the value of all registered modification time
columns to the current time. This will overwrite a column's value,
even if it has been already set.

=head1 SEE ALSO

=over 4

=item * DateTime

=item * DBIx::Class

=back

=head1 AUTHOR

=over 4

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=item * Adam Paynter E<lt>adapay@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

__PACKAGE__->mk_classdata( ctime_columns => [ ] );
__PACKAGE__->mk_classdata( mtime_columns => [ ] );

sub register_column {
    my( $class, $col, $info ) = @_;
    $class->next::method( $col, $info );
    
    if( my $type = $info->{ epoch } ) {
        $class->ctime_columns( [ @{ $class->ctime_columns }, $col ] ) if $type eq 'ctime';
        $class->mtime_columns( [ @{ $class->mtime_columns }, $col ] ) if $type eq 'mtime';
        
        $class->inflate_column(
            $col => {
                inflate => sub { DateTime->from_epoch( epoch => shift ) },
                deflate => sub { shift->epoch }
            }
        );
    }
}

sub insert {
    my $self = shift;
    my $time = time;
    
    for my $column ( @{ $self->ctime_columns }, @{ $self->mtime_columns } ) {
        next if defined $self->get_column( $column );
        $self->store_column( $column => $time );
    }

    $self->next::method( @_ );
}

sub update {
    my $self = shift;
    my $time = time;
    
    for my $column ( @{ $self->mtime_columns } ) {
        $self->set_column( $column => $time );
    }
    
    $self->next::method( @_ );
}

1;