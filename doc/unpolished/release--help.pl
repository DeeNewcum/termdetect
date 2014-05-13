#!/usr/bin/perl

# Update the "--help" link at:
#       https://github.com/DeeNewcum/termdetect/tree/master/doc#termdetect
# to point to the correct line of the source file.

    use strict;
    use warnings;

    use Data::Dumper;
    #use Devel::Comments;           # uncomment this during development to enable the ### debugging statements

## find the correct line number
open FIN, '<', '../../src/termdetect'
        or die $!;
my $line_num;
while (<FIN>) {
    if (/^__END__$/) {
        $line_num = $. + 1;
        last;
    }
}

if (!defined($line_num)) {
    die "Couldn't find the correct line.\n\t";
}

## update the hyperlink
my @README = slurp("../README.md");
foreach (@README) {
    if (/termdetect --help/) {
        s/termdetect#L\d+-/termdetect#L$line_num-/;
        last;
    }
}
            #print @README; exit;
open FOUT, '>', '../README.md'      or die $!;
print FOUT @README;
close FOUT;



# quickly read a whole file
# equivalent to File::Slurp or IO::All->slurp
sub slurp {my$p=open(my$f,"$_[0]")or die$!;my@o=<$f>;close$f;waitpid($p,0);wantarray?@o:join("",@o)}
