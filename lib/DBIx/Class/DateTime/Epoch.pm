package DBIx::Class::DateTime::Epoch;

use strict;
use warnings;

use base qw( DBIx::Class );

use DateTime;

__PACKAGE__->mk_classdata( ctime_columns => [ ] );
__PACKAGE__->mk_classdata( mtime_columns => [ ] );

sub register_column {
    my( $class, $col, $info ) = @_;
    $class->next::method( $col, $info );
    
    if( my $type = $info->{ datetime } ) {
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