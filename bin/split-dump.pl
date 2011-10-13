#/usr/bin/env perl 

use strict;
use warnings;

$/=undef;
my $cdir = './sources/c';
my $f90dir = './sources/f90';

my $dump = <STDIN>; # slurp dump

my @examples = split("\n>>><<<\n",$dump);

foreach my $code (@examples) {
  my @lines = split("\n",$code);
  my @meta = ();
  my @source = ();
  my ($name,$ext,$type,$expect,$filename,$dir) = undef;
  my $skip = undef;
  foreach my $line (@lines) {
    if ($line =~ m/@\@/) {
      push(@meta,$line);
      if ($line =~ m/name:[ \t]*(.+) *$/) {
        $name = $1;
      }
      if ($line =~ m/ext:[ \t]*(.+) *$/) {
        $ext = $1; 
        $dir = ($ext eq 'c') ? $cdir : $f90dir;
      }
      if ($line =~ m/type:[ \t]*(.+) *$/) {
        $type = $1;  # should be 'complete' or 'partial'
#$skip=1 if ($type ne 'complete');
      }
      if ($line =~ m/expect:[ \t]*(.+) *$/) {
        $expect = $1; 
      }
    } 
    push(@source,$line);
  }
  if ($name && $ext && !$skip) {
    $filename = sprintf("%s/%s/%s.%s",$dir,$type,$name,$ext);
    unlink($filename) if (-e $filename);
    open(FH,">$filename");
      print FH join("\n",@source);
    close(FH)
  }
}
