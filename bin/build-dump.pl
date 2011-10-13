#!/usr/bin/env perl

# alpha software, use at own risk :)

use strict;
use warnings;

my $cat = undef;
my $file = undef;
my $example = undef;
my $ext = undef;
my $code = undef; 
my $type_guess = undef;
my %examples=();
while (<>) {
  if ($_ =~ m/Example ([A]\.[\d]+\.[\d]+)([fc])/) {
    $example = "$1$2";
    $examples{$example}++;
    $ext = ($2 eq 'f') ? 'f90' : 'c';
    $file = sprintf("%s.%s",$example,$ext);
    $cat = 1;
    $code = '';
  } elsif ($cat) {
    # look for end of code marker(s), else cat $code
    if ($_ =~ m/^ +Fortran *$|^ +C\/C\+\+ *$/m) {
      if ($ext eq 'c') {
        $code = beautify_c($code);
        $type_guess = guess_type_c($code);
        my $main = ($type_guess eq 'partial') ? complete_c() : '';
        print<<END;
/*
  \@\@name:\t$example
  \@\@ext:\t$ext
  \@\@type:\t$type_guess
  \@\@*compilable: yes
  \@\@*compilable: no 
  \@\@*compilable: maybe 
  \@\@*expect:\tsuccess
  \@\@*expect:\tfailure
  \@\@*expect:\tnothing
*/
$main
END
      } elsif ($ext eq 'f' or $ext eq 'f90') {
        $code = beautify_f($code);
        $type_guess = guess_type_f($code);
        print<<END;
! \@\@name:\t$example
! \@\@ext:\t$ext
! \@\@type:\t$type_guess
! \@\@*compilable: yes
! \@\@*compilable: no 
! \@\@*compilable: maybe 
! \@\@*expect:\tsuccess
! \@\@*expect:\tfailure
! \@\@*expect:\tnothing
END
      }  
      printf("%s\n>>><<<\n",$code);
      $cat = undef;
    } elsif($_ !~ m/OpenMP API|^ +Appendix|^ *$/) { # skip footer 
      $_ =~ s/^ *[\d]+//;
      $code .= $_; 
    }
  } 
} 

sub complete_c {
  return<<END;
/*-- inserted as an attempt to generate a compilable program  --*/
#include <stdio.h>
#include <omp.h>
int main(){
  return 0;
}
END
}

#-- not currently used
sub complete_f {
  return<<END;
      PROGRAM FAKE 
       print *, "Hello, Earth!"
      END PROGRAM FAKE
END
}

sub beautify_c {
  my $code = shift;
  my @lines = split("\n",$code);
  my $min = 100000;
  my $leading = undef;
  my @ret = ();
  foreach my $line (@lines) {
    push(@ret,$line) if ($line !~ m/^ *$/);
    if ($line !~ m/^ *\#/) {
      $line =~ m/^( +)/;
      if ($1) {
        my $len = length($1);
        $min = $len if ($len < $min);
      }  
    }
  }
  $code = join("\n",@ret);
  $code =~ s/^ *(\#pragma)/$1/gm;
  $code =~ s/^ {0,$min}//gm;
  return $code;
}

sub beautify_f {
  my $code = shift;
  my @lines = split("\n",$code);
  my $min = 100000;
  my $leading = undef;
  my @ret = ();
  foreach my $line (@lines) {
    push(@ret,$line) if ($line !~ m/^ *$/);
    if ($line !~ m/^ *!\$/) {
      $line =~ m/^( +)/;
      if ($1) {
        my $len = length($1);
        $min = $len if ($len < $min);
      }  
    }
  }
  $code = join("\n",@ret);
  $min = ($min < 6) ? 6 : $min - 6; 
  $code =~ s/^ *(!\$OMP)/$1/gm;
  $code =~ s/^ {1,$min}//gm;
  return $code;
}

sub guess_type_c {
  my $code = shift;
  my $ret = 'partial';
  if ($code =~ m/ +main/gm) {
    $ret = 'complete';
  }
  return $ret;
}

sub guess_type_f {
  my $code = shift;
  my $ret = 'partial';
  if ($code =~ m/ +PROGRAM/igm || $code =~ m/ +SUBROUTINE/igm) {
    $ret = 'complete';
  } 
  return $ret;
}

# report on NOT FOUND using <DATA>

my $icount = 0;
my $count = 0;
while(<DATA>) {
  chomp;
  if (!exists($examples{$_})) {
    printf ("missing: %s\n",$_); 
    $count++;
  } else {
    $icount++;
  }
}
print STDERR "Apparently, missing $count expected examples. Found $icount\n";

1;

# this list is generated using a grep/awk over the pdftotext of the
# PDF created from Framemaker (non-LaTeX)
__DATA__
A.1.1c
A.1.1f
A.2.1c
A.2.1f
A.2.2c
A.2.2f
A.2.3c
A.2.3f
A.3.1c
A.3.1f
A.4.1c
A.4.1f
A.5.1c
A.5.1f
A.6.1c
A.6.1f
A.6.2c
A.6.2f
A.7.1f
A.7.2f
A.8.1f
A.8.2f
A.9.1c
A.9.1f
A.9.2c
A.9.2f
A.10.1c
A.10.1f
A.10.2c
A.10.2f
A.10.3c
A.10.3f
A.11.1c
A.11.1f
A.12.1c
A.12.1f
A.13.1c
A.13.1f
A.13.2c
A.13.2f
A.13.3c
A.13.3f
A.13.4c
A.13.4f
A.13.5c
A.13.5f
A.13.6c
A.13.6f
A.13.7c
A.13.7f
A.13.8c
A.13.8f
A.13.9c
A.13.9f
A.13.10c
A.13.10f
A.14.1f
A.14.2f
A.14.3f
A.14.4f
A.14.5f
A.14.6f
A.14.7f
A.15.1c
A.15.1f
A.16.1c
A.16.1f
A.17.1c
A.17.1f
A.18.1c
A.18.1f
A.19.1c
A.19.1f
A.20.1c
A.20.1f
A.20.2c
A.20.2f
A.20.3f
A.21.1c
A.21.1f
A.22.1c
A.22.1f
A.22.2c
A.22.2f
A.23.1c
A.23.1f
A.23.2c
A.23.2f
A.23.3c
A.23.3f
A.24.1c
A.24.1f
A.24.2c
A.24.3c
A.24.2f
A.24.3f
A.24.4f
A.24.5f
A.24.6f
A.24.4c
A.24.5c
A.25.1c
A.26.1f
A.26.2f
A.26.3f
A.26.4f
A.26.5f
A.27.1c
A.27.1f
A.28.1f
A.29.1c
A.29.1f
A.29.2c
A.29.2f
A.29.3c
A.29.3f
A.30.1f
A.30.2f
A.30.3f
A.30.4f
A.30.5f
A.31.1c
A.32.1c
A.32.1f
A.33.1c
A.33.1f
A.33.2c
A.33.2f
A.33.3f
A.33.4f
A.33.5f
A.33.3c
A.33.6f
A.34.1c
A.34.1f
A.35.1c
A.35.1f
A.35.2c
A.35.2f
A.35.3c
A.35.3f
A.35.4f
A.36.1c
A.36.1f
A.36.2c
A.36.2f
A.37.1c
A.37.1f
A.37.2c
A.37.2f
A.37.3c
A.37.3f
A.37.4c
A.37.4f
A.37.5c
A.37.5f
A.37.6c
A.37.6f
A.38.1c
A.38.1f
A.39.1c
A.39.1f
A.39.2c
A.39.2f
A.40.1c
A.40.1f
A.41.1c
A.41.1f
A.42.1c
A.42.1f
A.43.1c
A.43.1f
