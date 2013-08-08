package PhysVecRole;
# ABSTRACT: Role for a physical object that  varies in space or time. 
use Moose::Role;
use Carp;


has 'name'   ,    is => 'rw', isa => 'Str' ;

has 'mass'   ,    is => 'rw', isa => 'Num' , lazy=>1, default => 0;  

has 't'      ,    is => 'rw', isa => 'Int|ScalarRef' ,  default => 0;

my @t_dep = qw(coords forces charges); 

has "_t$_"  => (
                traits   => [ 'Array' ],
                isa      => 'ArrayRef',
                default  => sub { [] },
                handles  =>
                {
                  "add_$_" => 'push'    ,
                  "get_$_" => 'get'     ,
                  "set_$_" => 'set'     ,
                  "all_$_" => 'elements',
                "count_$_" => 'count'   ,
                },
                lazy   => 1,
               ) for @t_dep;


has 'units'  ,    is => 'rw', isa => 'Str'  ; #flag for future use [SI]

has 'origin' => (
                 is      => 'rw', 
                 isa     => 'ArrayRef', 
                 default => sub{[0,0,0]},
                 lazy    => 1,
                );

has 'xyzfree' => (  
                  is      => 'rw', 
                  isa     => 'ArrayRef[Int]', 
                  default => sub{[1,1,1]},
                  lazy    => 1,
                 );

has 'charge' => (
     is         => 'rw',
     isa        => 'Num',
     builder    => '_build_charge',
     lazy       => 1,
                ); 

sub _build_charge {
  my $self = shift;
  if ($self->count_charges){
    return ( $self->get_charges($self->t) );
  }
  else {
    return (0);
  }
}


1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

The PhysVecRole provides the core attributes and methods shared between Atom and 
Molecule classes.
Consuming this role gives Classes a place to store coordinates, forces, and 
charges, perhaps, over the course of a simulation or for a collection 
configurations for
which all other object meta-data (name, mass, etc) remains fixed. As such, the
't' attribute, described below, is important to understand. As of Version
0.001, the PhysVecRole is very flexible. Several attribute types are left 
agnostic and rw so that they may be filled with whatever the user defines them to be... on the fly.  This seems most intuitive from the perspective of carrying 
out computational work on molecules. 
One example that could take advantage of the flexibility: A molecule consumes 
PhysVecRole so 
it has an array of coordinates for itself that is likely to remain empty 
(because the atoms that Molecule contains have the more useful coordinates).  
For much larger systems, the atoms may be ignored while the Molecule t-dependent 
coordinate array could be filled with PDLs from Perl Data Language for much 
faster analyses. Future version may tighten the API and perhaps fork off new 
roles that are more specific to the scale of the problem. 

=attribute
name

isa Str that is rw. useful for labeling, bookkeeping...

=attribute
t

isa Int or ScalarRef that is rw with default of 0

t is intended to describe the current "setting" of the object. Objects that 
consume the PhysVecRol have  arrays of coordinates, forces, and charges to 
allow storage with the passing of time (hence t) or the generation alternative 
configurations.  For example, a crystal lattice can be stored as a single 
object that consumes PhysVecRole (with associated metadata) along with the 
array of 3d-coordinates resulting from lattice vector translations. 

Experimental: Setting t to a ScalarRef allows all objects to share the same t.  
Although, to use this, a $self->t accessor that dereferences the value would 
seem to be required.  There is nothing, currently, in the core to do so. Not 
sure yet if it is a good or bad idea to do so.

    my $t  = 0;
    my $rt = \$t;  
    $_->t($rt) for (@objects);
    $t = 1; # change t for all objects.

=attribute
mass 

isa Num that is rw and lazy with a default of 0

=attribute
xyzfree

isa ArrayRef that is rw and lazy with a default value [1,1,1]. Using this array
allows the object to be fixed for calculations that support it.  To fix X, $

=attribute
charge

lazy, default: (build from t-dependent charges) or 0
 
As decribed in ARRAY_ATTRIBUTES, atoms and molecules have t-dependent arrays 
of charges for the purpose of analysis.  e.g. one could store and analyze 
atomic charges 
from a quantum mechanical molecule in several intramolecular configurations 
or under varying environmental influences.  

Often thinking in terms of a given atom/molecule having a "charge" is more
intuitive and convenient.  The default value of the "charge" attribute is 
the t index of "charges" or 0.0 if "charges" have been cleared. 

=private_attribute
_tcharges _tcoords _tforces

isa ArrayRef that is lazy with public ARRAY traits described in ARRAY_METHODS
 
Gives atoms and molecules t-dependent arrays of charges, coordinates, and forces,
for the purpose of analysis.  e.g. store and analyze atomic charges from a 
quantum mechanical molecule in several intramolecular configurations or a fixed 
configuration in varied external potentials.   

The types of the attributes are left agnostic so that they may be filled with 
whatever the user defines them to be.  Perhaps this is too flexible? One example 
to argue for the flexibility: A molecule consumes PhysVecRole so it has an array 
of coordinates for itself that is likely to remain empty (because the atoms that 
Molecule contains have the more useful coordinates).  For much larger systems, 
the atoms may be ignored while the Molecule t-dependent coordinate array could 
be filled with PDLs from Perl Data Language.  
=cut


=array_method

=over 4       

 add_charges    add_coords    add_forces       => push 
 get_charges    get_coords    get_forces       => get  
 set_charges    set_coords    set_forces       => set
 all_charges    all_coords    all_forces       => elements
 count_charges  count_coords  count_forces     => count

=back 

examples: 
add_charges(-0.1)
