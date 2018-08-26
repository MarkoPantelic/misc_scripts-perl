#!/usr/bin/env perl

#===================================
# ------------ Pager --------------
#
# Read file by file in directory
# 6.7.2018
#===================================

#===============================================
#            -- usage --
# pager.pl [string directory_path] [bool recurse]
#
# Dependency: Term::ReadKey 
# (cpan install Term::ReadKey)
#===============================================


# TODO:
# cmdline options with getopt or similar
# -n option (enumerate file lines)
# -e option (only read files with specified extension)


use warnings;
use strict;
use autodie;
use Data::Dumper qw( Dumper );
use Term::ReadKey ();
use File::stat;
#use Cwd qw( abs_path ); # if needed absolute file path


# multiplay char $n number of times
sub char_multiply {
  my ($char, $n) = @_;
  my $c = "";
  for(my $i=0; $i<$n; $i++) { $c .= $char };
  return $c . "\n";
}


sub get_filestat {
  my $filename = shift;
  my $sb = stat($filename);
  my $stat_str = sprintf "size: %s b, permissions: %04o, mtime %s",
  $sb->size, $sb->mode & 07777,
  scalar localtime $sb->mtime;

  return $stat_str;
}


# print filename enclosed by delimiters
sub print_filename {
  my $filename = shift;
  my $filestat = '   ->   ' . get_filestat($filename);
  my $delimit = char_multiply '-', length $filename;
  print $delimit. $filename . $filestat . "\n" . $delimit . "\n";
}


# code for pressed keyboard key read
sub keyboard_key_wait {

  my $key = undef;

  while(1) {
    $key = Term::ReadKey::ReadKey(0);
    
    # DEBUG
    #print "key -> $key \n";

    last if lc($key) eq 'q';

    if (ord($key) == 27) { #first byte of arrow keys multibyte char evals to 27
      # flush other received bytes from multibyte char
      while(defined Term::ReadKey::ReadKey(-1)) {
        ;;
      }
      last;
    }

    if (ord($key) == 3) { # CTRL + C is pressed
      print "$0: Keyboard interrupt with CTRL+C\n";
      exit(0);
    }
  }
  return $key;
}


=pod

traverse files()

arg1: string $dirname
arg2: bool $recurse

=cut

sub traverse_files {
  # Better use 'Path::Iterator::Rule' to traverse a directory tree ???
  my $key = undef;
  my $dirname = shift;
  my $recurse = shift || 0;

  opendir(my $dirh, $dirname);

  while(my $filename = readdir($dirh)) {

    $key = undef;

    next if ($filename eq '.' || $filename eq '..');
    $filename = $dirname . "/" . $filename;
    #$filename = abs_path($filename);

    if ( -f $filename) {

      open my $fh, '<', $filename;
      print char_multiply('=', 80);
      print_filename $filename;
      while(<$fh>) {
        print $_;
      }
      close $fh;
      print "\n" . char_multiply('=', 80) . "\n";

      $key = keyboard_key_wait();
      last if $key eq 'q' or $key eq 'Q';

      # DEBUG
      #print "key: '" . $key . "' pressed \n";

      sleep 0.1; # for key press hold

    } elsif ( -d $filename && $recurse) {
        traverse_files($filename, $recurse);
    } else {
      # "NOT A FILE";
    }

  } # end while my $filename

  closedir $dirh;
  return;
}


#========#
# main()
#========#

# set ReadKey terminal mode
Term::ReadKey::ReadMode 4;

my $start_dir = '.';
my $do_recursion = 0;

# get cmdline arguments
if (scalar @ARGV > 0) {
  $start_dir = $ARGV[0];
}
if (scalar @ARGV > 1) {
  $do_recursion = $ARGV[1];
}

#print "start dir = " . $start_dir . ", do recursion = " . $do_recursion . "\n";
traverse_files $start_dir, $do_recursion;

END { # !important
  # restore ReadKey terminal mode
  Term::ReadKey::ReadMode 0;
}
