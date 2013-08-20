use Modern::Perl;
use Test::Most;
use Test::Warnings;
use Test::Moose;
use Test::More;
use Math::Vector::Real;
use lib 'lib'; #/HackaMol';
use Time::HiRes qw(time);
use HackaMol::Atom;
use HackaMol::Bond;


my @attributes = qw(
atoms bond_order
);
my @methods = qw(
bond_length bond_vector 
);

my @roles = qw(AtomsGroupRole);

map has_attribute_ok( 'Bond', $_ ), @attributes;
map can_ok( 'Bond', $_ ), @methods;
map does_ok( 'Bond', $_ ), @roles;

my $atom1 = Atom->new(
    name    => 'Hg',
    charges => [2,2,2,2,2,2,2,2,2,2],
    coords  => [ 
                V( 0.0, 0.0, 0.0 ), 
                V( 0.0, 1.0, 0.0 ), 
                V( 0.0, 2.0, 0.0 ), 
                V( 0.0, 3.0, 0.0 ), 
                V( 0.0, 4.0, 0.0 ), 
                V( 0.0, 5.0, 0.0 ), 
                V( 0.0, 6.0, 0.0 ), 
                V( 0.0, 7.0, 0.0 ), 
                V( 0.0, 8.0, 0.0 ), 
                V( 0.0, 9.0, 0.0 ), 
               ],
    symbol  => 'HG'
);

my $atom2 = Atom->new(
    name    => 'C1',
    charges => [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
    coords  => [ 
                V( 0.0, 0.0, 0.0 ), 
                V( 1.0, 1.0, 0.0 ), 
                V( 2.0, 2.0, 0.0 ), 
                V( 3.0, 3.0, 0.0 ), 
                V( 4.0, 4.0, 0.0 ), 
                V( 5.0, 5.0, 0.0 ), 
                V( 6.0, 6.0, 0.0 ), 
                V( 7.0, 7.0, 0.0 ), 
                V( 8.0, 8.0, 0.0 ), 
                V( 9.0, 9.0, 0.0 ), 
               ],
    Z       => 6
);

my $atom3 = Atom->new(
    name    => 'C2',
    charges => [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
    coords  => [
                V( -1.0, 0.0, 0.0 ),
                V( -1.0, 1.0, 0.0 ),
                V( -2.0, 2.0, 0.0 ),
                V( -3.0, 3.0, 0.0 ),
                V( -4.0, 4.0, 0.0 ),
                V( -5.0, 5.0, 0.0 ),
                V( -6.0, 6.0, 0.0 ),
                V( -7.0, 7.0, 0.0 ),
                V( -8.0, 8.0, 0.0 ),
                V( -9.0, 9.0, 0.0 ),
               ],
    Z => 6,
);


my $bond1 = Bond->new(atoms => [$atom1,$atom2]);
my $bond2 = Bond->new(atoms => [$atom1,$atom3]);

foreach my $t (0 .. 9){
  $bond1->gt($t);
  cmp_ok($bond1->bond_length,'==', $t, "t dependent bond length: $t");
  is_deeply($bond1->bond_vector, V($t,0,0), "t dependent bond vector: V ($t, 0, 0)");
}

$atom1->set_coords($_, V(0,0,0)) foreach 0 .. 9;

foreach my $t (0 .. 9){
  $bond1->gt($t);
  cmp_ok(abs($bond1->bond_length - sqrt(2)*$t),'<', 0.000001, "t dependent bond length $t");
  is_deeply($bond1->bond_vector, V($t,$t,0), "t dependent bond vector: V ($t, 0, 0)");
}

is($bond1->bond_order, 1, "bond order default");
$bond1->bond_order(1.5);

is($bond1->bond_order, 1.5, "bond order set to num");
is($atom1->count_bonds, 2, "atom1 knows it has 2 bonds");
is($atom2->count_bonds, 1, "atom2 knows it has 1 bonds");
is($atom3->count_bonds, 1, "atom3 knows it has 1 bonds");
is($atom1->get_bonds(0),$bond1, 'the atom is aware of its bond');
is($atom2->get_bonds(0),$bond1, 'the atom is aware of its bond');
is($atom1->get_bonds(1),$bond2, 'the atom is aware of its bond');
is($atom3->get_bonds(0),$bond2, 'the atom is aware of its other bond');

$bond1->bond_fc(1.0);
$bond1->bond_length_eq($bond1->bond_length - 0.5);

cmp_ok (abs(0.25-$bond1->bond_energy),'<',1E-7, 'simple bond energy test') ;

done_testing();
