#!/usr/bin/env perl

use warnings;
use strict;
use File::Path;
use File::Copy;

use Tie::Hash::Indexed;
tie my %examples, 'Tie::Hash::Indexed';

foreach my $file (@ARGV) {
  open(FH,"<$file");
  while(<FH>) {
    if ($_ =~ m/^\[/) {
      chomp $_;
      my @tmp = split(' ',$_);
      push(@{$examples{$tmp[4]}}, {$tmp[2] => $tmp[3]}); 
    }
  }
  close(FH);
}

use Data::Dumper;
#print Dumper(\%examples);

# print header
my @row = ('<tr><th>Example</th>');
my @compilers = ();
foreach my $compiler (@ARGV) {
  push(@compilers,$compiler);
  # make directory for cross linking
  mkpath("./html/$compiler");
  push(@row,"<th>$compiler</th>");
}
push(@row,'</tr>');
printf("<table>\n%s\n",join('',@row));

# print results
foreach my $example (keys(%examples)) {
  my $exlink = $example;
  $exlink =~ s/\.\.\/\.\.\///g;
  @row = ("<tr><td><a href=./$exlink.txt>$exlink</a></td>");
  my $count = 0;
  foreach my $status (@{$examples{$example}}) {
    my @keys = keys(%{$status});
    if ($keys[0] eq 'FAIL') {
      copy($status->{$keys[0]},"./html/$compilers[$count]") or die "Copy failed: $!"; 
    }
    my @file = split('/',$status->{$keys[0]});
    my $file = pop @file;
    push(@row,sprintf("<td bgcolor=%s><font size=2>%s</font></td>",($keys[0] eq 'OKAY') ? 'green' : 'red',($keys[0] eq 'OKAY') ? $keys[0] : sprintf("<a href=./%s/%s>%s</a>",$compilers[$count],$file,$keys[0])));
    $count++;
  }
  push(@row,'</tr>');
  printf("%s\n",join('',@row));
}
print('</table>');
