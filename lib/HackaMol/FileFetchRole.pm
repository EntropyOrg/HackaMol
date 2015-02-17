package HackaMol::FileFetchRole;

#ABSTRACT: Role for using LWP::Simple to fetch files from www 
use Moose::Role;
use Carp;

has 'pdbserver',   is => 'rw', isa => 'Str', lazy => 1, default => 'http://pdb.org/pdb/files/';
has 'overwrite',   is => 'ro', isa => 'Bool', lazy => 1, default => 0;

sub _fix_pdbid{
  my $pdbid = shift;
  $pdbid =~ s/\.pdb//; #just in case
  $pdbid .= '.pdb';
  return $pdbid;
}

sub get_pdbid{
  #return array of lines from pdb downloaded from pdb.org
  use LWP::Simple;
  my $self = shift;
  my $pdbid = _fix_pdbid(shift);  
  my $pdb = get($self->pdbserver.$pdbid);
  return ( $pdb );
}

sub getstore_pdbid{
  #return array of lines from pdb downloaded from pdb.org
  use LWP::Simple;
  my $self = shift;
  my $pdbid = _fix_pdbid(shift);
  my $fpdbid = shift || $pdbid;
  if (-f $fpdbid and not $self->overwrite){
    carp "$fpdbid exists, set self->overwrite(1) to overwrite";
    carp "you can load this file using something like HackaMol->new->file_load_mol";
  }
  my $pdb = getstore($self->pdbserver.$pdbid,$fpdbid);
  return ( $pdb );
}

no Moose::Role;
1;

__END__

=head1 SYNOPSIS

   use HackaMol;

   my $pdb = $HackaMol->new->get_pdbid("2cba");
   print $pdb;

=head1 DESCRIPTION

FileFetchRole provides attributes and methods for pulling files from the internet.
Currently, the Role has one method and one attribute for interacting with the Protein Database.

=method get_pdbid 

fetches a pdb from pdb.org and returns the file in a string.

=method getstore_pdbid 

arguments: pdbid and filename for writing (optional). 
Fetches a pdb from pdb.org and does two things: 1. returns the file in a string (as does get_pdbid) 
and 2. stores it in your working directory unless {it exists and overwrite(0)}. If a filename is not
passed to the method, it will write to pdbid.pdb.

=attr overwrite    
 
isa lazy ro Bool that defaults to 0 (false).  If overwrite(1), then fetched files will be able to overwrite
those of same name in working directory.

=attr  pdbserver  

isa lazy rw Str that defaults to http://pdb.org/pdb/files/

=head1 SEE ALSO

=for :list
* L<http://www.pdb.org>
* L<LWP::Simple>
                              
