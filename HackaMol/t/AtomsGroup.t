use Test::Most;
use Test::Warnings;
use Test::Moose;
use MooseX::ClassCompositor;    #use this for testing roles
use lib 'lib/roles','lib/HackaMol';
use Math::Vector::Real;
use Atom;
use AtomsGroup;                # v0.001;#To test for version availability

my @attributes = qw(
atoms dipole COM COZ dipole_moment total_charge atoms_bin
);
my @methods = qw(
_build_dipole _build_COM _build_COZ _build_total_charge _build_dipole_moment 
clear_atoms_bin clear_dipole clear_dipole_moment clear_COM 
clear_COZ clear_total_charge clear_dipole_moment
set_atoms_bin get_atoms_bin has_empty_bin count_unique_atoms all_unique_atoms 
atom_counts canonical_name Rg all_atoms push_atoms get_atoms delete_atoms count_atoms
clear_atoms
);

my $class = MooseX::ClassCompositor->new( { 
                                            class_basename => 'Test', 
                                          } )->class_for('AtomsGroup');

map has_attribute_ok( $class, $_ ), @attributes;
map can_ok( $class, $_ ), @methods;
my $group;
lives_ok {
    $group = $class->new();
}
'Test creation of an group';

my $atom1 = Atom->new(
    name    => 'O',
    charges => [ -0.80, -0.82, -0.834 ],
    coords  => [ V(2.05274,        0.01959,       -0.07701) ],
    Z       => 8
);

my $atom2 = Atom->new(
    name    => 'H',
    charges => [0.4,0.41,0.417],
    coords  => [ V( 1.08388,        0.02164,       -0.12303 ) ],
    Z       => 1
);
my $atom3 = Atom->new(
    name    => 'H',
    charges => [0.4,0.41,0.417],
    coords  => [ V( 2.33092,        0.06098,       -1.00332 ) ],
    Z       => 1
);

$group->push_atoms($_) foreach ($atom1, $atom2, $atom3);

$group->do_forall('copy_ref_from_t1_through_t2','coords', 0, 2);

is($group->count_atoms, 3, 'atom count');

foreach my $at ($group->all_atoms){
  cmp_ok($at->get_coords(0) , '==' , $at->get_coords($_),
  "do_forall(copy_ref_from_t1_through_t2, coords, 0 , 2): $_") foreach 1 .. 2;
}

my @dipole_moments = qw(2.293 2.350 2.390);
$group->t(0);
foreach my $at ($group->all_atoms){
  is($at->t, 0, "group->t(0) for each atom in group");
}
$group->t(1);
foreach my $at ($group->all_atoms){
  is($at->t, 1, "group->t(1) for each atom in group");
}

foreach my $t (0 .. 2){
  $group->t($t);
  cmp_ok(abs($group->dipole_moment-$dipole_moments[$t]), '<' , 0.001, "dipole moment at t=$t");
}

my $atom4 = Atom->new(
    name    => 'H',
    charges => [0.0],
    coords  => [ V( 0,0,0 ) ],
    Z       => 1
);

my $atom5 = Atom->new(
    name    => 'H',
    charges => [0.0],
    coords  => [ V( 1,0,0 ) ],
    Z       => 1
);

my $atom6 = Atom->new(
    name    => 'H',
    charges => [0.0],
    coords  => [ V( 2,0,0 ) ],
    Z       => 1
);

$group->clear_atoms;
is($group->count_atoms, 0, 'atom clear atom count');

$group->push_atoms($atom4);
is($group->count_atoms, 1, 'atom atom count 1');
$group->push_atoms($atom5);
is($group->count_atoms, 2, 'atom atom count 2');

is_deeply($group->COM, V (0.5,0,0), 'Center of mass');
is_deeply($group->COZ, V (0.5,0,0), 'Center of Z');

$atom4->mass(1);
$atom5->mass(10);

is_deeply($group->COM, V (0.5,0,0), 'Center of mass');
is_deeply($group->COZ, V (0.5,0,0), 'Center of Z');

$group->push_atoms($atom6);

is($group->count_atoms, 3, 'atom atom count 3');
is_deeply($group->COM, V (1,0,0), 'Center of mass');
is_deeply($group->COZ, V (1,0,0), 'Center of Z');

$group->clear_atoms;
is_deeply($group->COM, V (0), 'Center of mass V (0) no atoms');
is_deeply($group->COZ, V (0), 'Center of Z V (0) no atoms');
is_deeply($group->dipole, V (0), 'Dipole V (0) no atoms');


$group->quick_push_atoms($atom1);
$group->quick_push_atoms($atom2);
$group->push_atoms($atom3);
is($group->count_unique_atoms, 2, 'unique atoms in water is 2');
is($group->canonical_name, 'OH2', 'water named OH2');

$group->push_atoms($atom1);
is($group->count_unique_atoms, 2, 'push O1 again, unique atoms still 2');
is($group->canonical_name, 'O2H2', 'now named O2H2');




done_testing();
