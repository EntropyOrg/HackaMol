use Modern::Perl;
use Test::Most;
use Test::Warnings;
use Test::Moose;
use Test::More;
use Math::Vector::Real;
use Time::HiRes qw(time);
use HackaMol::Atom;
use HackaMol::Dihedral;


my @attributes = qw(
atoms dihe_eq dihe_mult dihe_dphase dihe_fc 
);
my @methods = qw(
torsion_energy improper_dihe_energy dihe_deg dihe_rad
);

my @roles = qw(HackaMol::AtomGroupRole);

map has_attribute_ok( 'HackaMol::Dihedral', $_ ), @attributes;
map can_ok( 'HackaMol::Dihedral', $_ ), @methods;
map does_ok( 'HackaMol::Dihedral', $_ ), @roles;

my $atom0 = HackaMol::Atom->new(
    name    => 'C1',
    charges => [0],
    coords  => [
                V( 1.0, 1.0, 0.0 ),
               ],
    Z => 6,
);
my $atom1 = HackaMol::Atom->new(
    name    => 'S1',
    charges => [0],
    coords  => [
                V( 1.0, 0.0, 0.0 ),
               ],
    Z => 16,
);
my $atom2 = HackaMol::Atom->new(
    name    => 'S2',
    charges => [0],
    coords  => [ 
                V( -1.0, 0.0, 0.0 ), 
               ],
    Z       => 16
);
my $atom3 = HackaMol::Atom->new(
    name    => 'C2',
    charges => [0],
    coords  => [
                V( -1.0, -1.0, 0.0 ),
               ],
    Z => 6,
);

my $dihe= HackaMol::Dihedral->new(atoms => [$atom0,$atom1,$atom2,$atom3]);

cmp_ok($dihe->dihe_deg,'==', 180.0, "180 dihedral");
is_deeply($dihe->COM, V(0,0,0), "COM at 0,0,0");

$atom3->set_coords(0,V(-1.0,sqrt(2)/2,sqrt(2)/2));
cmp_ok($dihe->dihe_deg,'==', -45.0, "-45 dihedral");

$atom3->set_coords(0,V(-1.0,-sqrt(2)/2,-sqrt(2)/2));
cmp_ok($dihe->dihe_deg,'==', 135.0, "135 dihedral");

$dihe->dihe_eq($dihe->dihe_deg - 0.5);

$dihe->dihe_fc(0.0);
cmp_ok (abs(0.0-$dihe->improper_dihe_energy),'<',1E-7, 'improper force constant 0 returns energy of 0') ;
cmp_ok (abs(0.0-$dihe->torsion_energy),'<',1E-7, 'torsion force constant 0 returns energy of 0') ;
$dihe->dihe_fc(1.0);
cmp_ok (abs(0.25-$dihe->improper_dihe_energy),'<',1E-7, 'simple improper dihe energy test') ;

$dihe->dihe_mult(2);
$dihe->dihe_dphase(0.1);
cmp_ok(abs(0.9-$dihe->torsion_energy), '<', 1E-2, 'simple torsion energy test');

$dihe->torsion_energy_func(
                          sub {
                               my $a = shift;
                               my $sum = 0;
                               $sum += $_*$a->dihe_deg foreach (@_);
                               return($sum);
                              }
                          );

$dihe->improper_dihe_energy_func($dihe->torsion_energy_func);

cmp_ok (
        abs($dihe->torsion_energy(1,2,3,4) - 10*$dihe->dihe_deg),
        '<', 1E-7, 'new nonsense torsion energy'
       );

cmp_ok (
        abs($dihe->improper_dihe_energy(1,2,3,4) - 10*$dihe->dihe_deg),
        '<', 1E-7, 'new nonsense improper dihedral energy'
       );



done_testing();
