use warnings;
use strict;

=head1 NAME

BarnOwl::Module::Alias

=head1 DESCRIPTION

Provides ``aliases'' for class names, giving you the ability to render
long class names as shorter ones. Currently zephyr-only.

=cut

package BarnOwl::Module::Alias;

our $VERSION = 0.2;

my %aliases;

sub splitclass {
    my ($match, $class) = @_;
    return $class =~ /^((?:un)*)$match((?:[.]d)*)$/i;
}

my $cfg = BarnOwl::get_config_dir();
if(-r "$cfg/classmap") {
    open(my $fh, "<:encoding(UTF-8)", "$cfg/classmap") or die("Unable to read $cfg/classmap:$!\n");
    while(defined(my $line = <$fh>)) {
        next if $line =~ /^\s+#/;
        next if $line =~ /^\s+$/;
        my ($class, $alias) = split(/\s+/, $line);
        my ($un, $baseclass, $d) = splitclass(qr/(.+?)/, $class);
        unshift @{$aliases{lc($baseclass)}}, [$class, $alias];
    }
    close($fh);
}

{
    no warnings 'redefine';
    sub BarnOwl::Message::Zephyr::context {
        my $self = shift;
        my $class = $self->class;
        my ($un, $baseclass, $d) = splitclass(qr/(.+?)/, $class);
        exists $aliases{lc($baseclass)} or return $class;
        for my $i (@{$aliases{lc($baseclass)}}) {
            my ($aclass, $aalias) = @$i;
            if (my ($un, $d) = splitclass(qr/\Q$aclass\E/i, $class)) {
                return "$un$aalias$d";
            }
        }
        return $class;
    }
}

1;
