use warnings;
use strict;

=head1 NAME

BarnOwl::Module::Alias

=head1 DESCRIPTION

Provides ``aliases'' for class names, giving you the ability to render
long class names as shorter ones. Currently zephyr-only.

=cut

package BarnOwl::Module::Alias;

my %aliases;

my $cfg = BarnOwl::get_config_dir();
if(-r "$cfg/classmap") {
    open(my $fh, "<", "$cfg/classmap");
    while(my $line = <$fh>) {
        next if /^\s+#/;
        next if /^\s+$/;
        my ($class, $alias) = split(/\s+/, $line);
        $aliases{$class} = $alias;
    }
    close($fh);
}

{
    no warnings 'redefine';
    sub BarnOwl::Message::Zephyr::context {
        my $self = shift;
        my $class = $self->class;
        my ($un, $baseclass, $d) = $class =~ /^((?:un)*)(.+?)((?:[.]d)*)$/;
        $baseclass = $aliases{$baseclass} || $baseclass;
        return "$un$baseclass$d";
    }
}

1;
