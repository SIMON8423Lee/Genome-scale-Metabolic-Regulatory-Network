#!/usr/bin/perl -w

use strict;
use Cwd;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);

my $ver="1.0.0";
############################
my %opts;
GetOptions(\%opts,"Anno=s","go=s","kegg=s","obo=s","h");
if (!defined($opts{Anno}) || !defined($opts{go}) || !defined($opts{obo})|| !defined($opts{kegg})|| defined($opts{h})) {
        &help;
        exit;
}

open ANNO,"$opts{Anno}" ||die "open Annotions error";

open KEGG,">$opts{kegg}" || die "out kegg error";
print KEGG "PATHWAY\tGENE\tKEGG_GENE\n";

my %go=();
while (my $Line = <ANNO>) {
        next if ($Line =~ /^#/);
        chomp $Line;
        my @temp = split(/\t/,$Line);

        my @Fi = split(/,/,$temp[9]);
        for ( @Fi ){
                $go{$_}{$temp[0]}=1;
        }

        my $kegg = join("\t",@temp[0,12]);
        my @FI = split(/[\t,]/,$kegg);
        for ( $a=1 ; $a<=($#FI) ; $a=$a+1 ){
                if ($FI[$a] =~ /^ko/){
                        print KEGG "$FI[$a]\t$FI[0]\t$temp[11]\n";
                };
        }
}

open OBO,"$opts{obo}" ||die "open obo file error";

open GO ,">$opts{go}" || die "out go error";
print GO "GO\tGENE\tCLASS\n";

my %Fi=();
while (my $Line = <OBO>) {
        chomp $Line;
        my @Fi = split(/[\t]/,$Line);
        $Fi{$Fi[0]}=$Fi[2];


}

foreach my $key(keys %go){
                foreach my $key2 ( keys %{$go{$key}}){
                        if (exists $Fi{$key}){
                                my @se = ($key,$key2,$Fi{$key});
                                print GO join("\t",@se)."\n";
                        }
                }
}

close(ANNO);
close(OBO);
close(KEGG);
close(GO);


sub help{
        print <<"Usage End.";
        Description:
                Function : Extracting GO and KEGG annotation information of gene.
                Version : $ver.
                Usage :
                        -Anno ---the Annotation file ;
                        -obo ----the GO obo data file ;
                        -go -----out go annotaion file, eg: GO:0000003  ATMG00550       biological_process ;
                        -kegg ---out kegg annotation file, eg: ko02010  ATMG00010       ko:KO5658 ;

Usage End.
}
