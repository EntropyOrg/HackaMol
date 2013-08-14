use Modern::Perl;
use Test::Most;
use Test::Warnings;
use Test::Moose;
use Test::More;
use lib 'lib/HackaMol';
use Atom;

my @attributes = qw( name t mass xyzfree is_fixed
                     distance_coderef inter_vector_coderef 
                     is_dirty symbol Z vdw_radius covalent_radius
                   );
my @methods = qw(
  _build_mass _build_symbol _build_Z _build_covalent_radius _build_vdw_radius
  change_Z  change_symbol _clean_atom
  distance delta_coords delta_forces delta_charges
);

my @pdb_attributes = qw(
record_name
serial    
occ       
bfact     
resname   
chain     
altloc    
resid     
iatom     
icode     
pdbid     
segid     
);

my @qm_attributes = qw(
basis
ecp
multiplicity
basis_geom
dummy
);
#todo add tests for storage!

my @roles = qw(PdbRole QmRole PhysVec BondsAnglesDihedrals);

map has_attribute_ok( 'Atom', $_ ), @attributes;
map can_ok( 'Atom', $_ ), @methods;
map does_ok( 'Atom', $_ ), @roles;
map has_attribute_ok( 'Atom', $_ ), @pdb_attributes;
map has_attribute_ok( 'Atom', $_ ), @qm_attributes;

my $atom1 = Atom->new(
    name    => 'C',
    charges => [-1],
    coords  => [ [ 3.12618, -0.06060, 0.05453 ] ],
    Z       => 6
);
my $atom2 = Atom->new(
    name    => 'Hg',
    charges => [2],
    coords  => [ [ 1.04508, -0.06088, 0.05456 ] ],
    symbol  => 'HG'
);
my $atom3 = Atom->new(
    name    => 'H1',
    charges => [0],
    coords  => [ [ 3.50249, 0.04320, -0.98659 ] ],
    symbol  => 'H'
);
my $atom4 = Atom->new(
    name    => 'H2',
    charges => [0],
    coords  => [ [ 3.50252, 0.78899, 0.66517 ] ],
    Z       => 1
);
my $atom5 = Atom->new(
    name    => 'H3',
    charges => [0],
    coords  => [ [ 3.50247, -1.01438, 0.48514 ] ],
    Z       => 1
);

my @atoms = ( $atom1, $atom2, $atom3, $atom4, $atom5 );

is( $atom1->symbol, 'C',  'Z      =>  6 generates symbol C ' );
is( $atom2->symbol, 'Hg', 'symbol => HG generates symbol Hg' );
is( $atom2->Z,      80,   'symbol => HG generates Z      80' );
is( $atom3->Z,      1,    'symbol => H  generates Z      1 ' );
is( sprintf( "%.2f", $atom1->distance($atom2) ),
    2.08, 'MeHg+ : C to Hg distance' );
is( sprintf( "%.2f", $atom1->distance($atom3) ),
    1.11, 'MeHg+ : C to H distance' );
is( sprintf( "%.2f", $atom1->distance($atom4) ),
    1.11, 'MeHg+ : C to H distance' );
is( sprintf( "%.2f", $atom1->distance($atom5) ),
    1.11, 'MeHg+ : C to H distance' );
is( sprintf( "%.2f", $atom3->distance($atom4) ),
    1.81, 'MeHg+ : H to H distance' );
is( sprintf( "%.2f", $atom3->distance($atom5) ),
    1.81, 'MeHg+ : H to H distance' );

my ( $bin, $elname ) = bin_atoms( \@atoms );
is( $elname, 'C1H3Hg1',
"name sorted by symbol constructed from binned atom symbols (C1H3Hg1) as expected"
);

my ( $prnts, $sum_mass ) = elemental_analysis( $bin, $elname );

is( sprintf( "%.2f", $sum_mass ), 215.62, "mass of MeHg+ sums as expected" );
is(
    $prnts->[0],
    " H     1.0079     3   1.40\n",
    "H  in elemental analysis as expected"
);
is(
    $prnts->[1],
    " C    12.0107     1   5.57\n",
    "C  in elemental analysis as expected"
);
is(
    $prnts->[2],
    "Hg   200.5900     1  93.03\n",
    "Hg in elemental analysis as expected"
);
ok( !$atom2->is_dirty, "atom 2 is clean" );
warning_is { $atom2->change_Z(30) }
"cleaning atom attributes for in place change. setting atom->is_dirty",
  "warning from changing Z";
is( $atom2->symbol, 'Zn', "atom 2 changed from Hg to Zn" );
ok( $atom2->is_dirty, "atom 2 is now dirty" );

( $bin, $elname ) = bin_atoms( \@atoms );
( $prnts, $sum_mass ) = elemental_analysis( $bin, $elname );
is( $elname, 'C1H3Zn1',
"name sorted by symbol constructed from binned atom symbols (C1H3Zn1) as expected"
);
is( sprintf( "%.2f", $sum_mass ), 80.42, "mass of MeHg+ sums as expected" );
is(
    $prnts->[0],
    " H     1.0079     3   3.76\n",
    "H  in elemental analysis as expected"
);
is(
    $prnts->[1],
    " C    12.0107     1  14.93\n",
    "C  in elemental analysis as expected"
);
is(
    $prnts->[2],
    "Zn    65.3900     1  81.31\n",
    "Zn in elemental analysis as expected"
);

done_testing();

sub bin_atoms {
    my $atoms = shift;
    my %bin;
    $bin{ $_->symbol }++ foreach @{$atoms};
    my $elname;
    $elname .= $_ . $bin{$_} foreach ( sort keys %bin );
    return ( \%bin, $elname );
}

sub elemental_analysis {
    my $atom_bin = shift;
    my $label    = shift;
    my @atoms =
      map { Atom->new( symbol => $_, iatom => $atom_bin->{$_} ) }
      keys %{$atom_bin};

    @atoms = sort { $a->mass <=> $b->mass } @atoms;
    my $mass_sum = 0;
    $mass_sum += $_->iatom * $_->mass foreach @atoms;
    my @prnts = map {
        sprintf( "%2s %10.4f %5i %6.2f\n",
            $_->symbol, $_->mass, $_->iatom,
            100 * $_->iatom * $_->mass / $mass_sum )
    } @atoms;

    return ( \@prnts, $mass_sum );
}
