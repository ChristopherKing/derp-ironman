#!/usr/bin/perl 
#===============================================================================
#
#         FILE: final.pl
#
#  DESCRIPTION: This is the final project program for ITM 302. It displays a
#               menu for the user to choose one of five options and then performs
#               that action.
#
#               On another note, the style of my programming may have changed 
#               slightly as I am now using a pretty cool vim setup with a lot of
#               features like code completion, inserting code/comment snippets,
#               etc. I am using spf13 vim along with the perl-support.vim plugin.
#
#       AUTHOR: Christopher King , cking4@hawk.iit.edu
# ORGANIZATION: Illinois Institute of Technology
#       COURSE: ITM 302
#    PROFESSOR: Jeremy Hajek
#      VERSION: 1.0
#      CREATED: 11/25/2012 12:06:10 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Tie::File;
use POSIX;

print "Welcome to Christopher King's ITM 302 Final Project.\n";
while(1) {
    &displayMenu();
    chomp(my $choice = <>);
    if($choice == 1) {
        &option1();
    }
    elsif($choice == 2) {
        &option2();
    }
    elsif($choice == 3) {
        &option3();
    }
    elsif($choice == 4) {
        &option4();
    }
    elsif($choice == 5) {
        &option5();
    }
    elsif($choice == 6) {
        print "Exiting...\n";
        exit(0);
    }
    else {
        print "You entered an invalid choice. Please try again.\n";
    }
}

#===  FUNCTION  ================================================================
#         NAME: option1
#   PARAMETERS: none
#      RETURNS: nothing
#  DESCRIPTION: This function performs the first option of the menu. It first
#               asks the user for the name of a log file to parse. Then it loops
#               through the named file printing all lines the contain the given
#               IP address to both STDOUT and to another log file with the
#               current time as its name.
#       THROWS: no exceptions
#===============================================================================
sub option1
{
    print "Please enter the name of a log file:\n";
    chomp(my $fileName = <>);
    my @time = localtime(time);
    my $timeString = "$time[4]-$time[3]-" . ($time[5]+1900) . "_$time[2]-$time[1]";
    print "Now searching for lines containing 99.120.59.68...\n";
    open(my $readfile, "<", "$fileName");
    open(my $writefile, ">", "$timeString");

    print "Writing to a file named: $timeString\n";
    while(<$readfile>) {
        my $line = $_;
        if(index($line, "99.120.59.68") != -1) {
            print "$line";
            print $writefile "$line";
        }
    }

}

#===  FUNCTION  ================================================================
#         NAME: option2
#   PARAMETERS: none
#      RETURNS: nothing
#  DESCRIPTION: This function performs the second option of the menu. It first
#               asks the user for the neccessary information to create a new
#               user (name, groupid, and shell). It then validates the input and
#               inserts it into a hash. Finally it appends the values from the
#               hash to a "passwd" file in the usual convention for that file.
#               (Values on one line seperated by the ":" character)
#       THROWS: no exceptions
#===============================================================================
sub option2
{
    print "Please enter the following information:\n";
    print "\tName: ";
    chomp(my $name = <>);
    print "\tGroup ID: ";
    chomp(my $gid = <>);
    if($gid eq "") {
        $gid = "7899";
    }
    my $shell = "";
    while(($shell ne "/bin/bash") && ($shell ne "/bin/sh")) {
        print "\tShell (/bin/bash or /bin/sh): ";
        chomp($shell = <>);
    }
    my %user = ('name' => "$name",
                'gid' => "$gid",
                'shell' => "$shell");
    open(my $writefile, ">>", "passwd");
    print "Writing data to passwd file...\n";
    print $writefile "$user{'name'}:$user{'gid'}:$user{'shell'}\n";
}


#===  FUNCTION  ================================================================
#         NAME: option3
#   PARAMETERS: none
#      RETURNS: nothing
#  DESCRIPTION: This function performs the third option in the menu. It first
#               asks the user for the name of a file. Then it inserts a comment
#               concerning copyright information into the file after the "#!"
#               line  Since this line is always the first line of a file/script
#               we just insert the information after the first line.
#
#               In order to do this easily I used the Tie::File module. This 
#               allowed me to manipulate the file like it was an array meaning
#               I could just use an array splice to insert an "element" (in this
#               case a line) into the "array" (in this case a file).
#
#               If the Tie module was unavailable then to perform this task you
#               would have to read in the file either to memory or into a temp
#               file line by line. After copying the line before where you would
#               like to insert you would write the information you wanted to
#               insert to the temp file/memory location. Then you would finish
#               copying the rest of the file. After this you would rewrite the
#               file or rename/move the temp file over the original file. As
#               you can tell this is much more complicated then simply using the
#               Tie::File module.
#       THROWS: no exceptions
#===============================================================================
sub option3
{
    print "Please enter a filename to insert into: ";
    chomp(my $fileName = <>);
    tie my @file, 'Tie::File', "$fileName";
    splice @file, 1, 0, "## Copyright (C) 2012 by Christopher King";
    untie @file;
    print "Finished inserting.\n"
}


#===  FUNCTION  ================================================================
#         NAME: option4
#   PARAMETERS: none
#      RETURNS: nothing
#  DESCRIPTION: This function performs the fourth menu option. First it asks the
#               user to enter a directory (relative or absolute path). Then it
#               asks if the user would like long or short form directory listing
#               (ls or ls -la). It then executes the corresponding command
#               printing the results to STDOUT. All input is validated and the
#               user is able to choose whether they would like to try again
#               if there is a problem with ls.
#       THROWS: no exceptions
#===============================================================================
sub option4
{
    while (1) {
        print "Please enter a directory to list on screen: ";
        chomp(my $directory = <>);
        my $choice; #Declare some variables so they stay in scope for all these loops 
        my $result;
        while (1) {
            print "Would you like long or short form (L or S): ";
            chomp($choice = <>);
            $choice = uc($choice);
            if ($choice eq 'L') {
                $result = system("ls -la $directory");
                last;
            }
            elsif($choice eq 'S') {
                $result = system("ls $directory");
                last;
            }
            else {
                print("You did not enter valid input.\n");
            }
        }
        if ($result == 0) {
            last;
        }
        else {
            print "There was an issue executing the command.\n";
            while (1) {
                print "Would you like to try again? (Y/N): ";
                chomp($choice = <>);
                $choice = uc($choice);
                if($choice eq 'Y') {
                    last;
                }
                elsif($choice eq 'N') {
                    return;
                }
                else {
                    print "You did not enter valid input.\n";
                }
            }
        }
    }
}


#===  FUNCTION  ================================================================
#         NAME: option5
#   PARAMETERS: none
#      RETURNS: nothing
#  DESCRIPTION: This function performs the fifth option in the menu. It first
#               asks the user for the name of a file containing random numbers.
#               It then reads in the numbers, storing them in an array, and 
#               calculates the mean, mode, median, and standard deviation of the
#               dataset. It prints each of these statistics to STDOUT.
#       THROWS: no exceptions
#===============================================================================
sub option5
{
    use Math::BigFloat;
    print "Please enter the name or path of the file to be read: ";
    chomp(my $fileName = <>);
    open(my $file, "<", "$fileName");
    my @numbers = ();
    while(<$file>) {
        push(@numbers, Math::BigFloat->new("$_"));
    }
    #&mean(@numbers);
    &mode(@numbers);
    &median(@numbers);
    &standardDeviation(@numbers);
}

#===  FUNCTION  ================================================================
#         NAME: mean
#   PARAMETERS: a list of numbers
#      RETURNS: the mean of the numbers in the list
#  DESCRIPTION: This function gets the mean of a set of numbers. It first
#               calculates the sum of the numbers then divides that by the
#               length of the array (the number of numbers). It then returns the
#               value as well as printing it to STDOUT.
#       THROWS: no exceptions
#===============================================================================
sub mean 
{
    use Math::BigFloat;
    my @array = @_;
    my $sum = Math::BigFloat->new(&sum(@array));
    my $mean = $sum/scalar(@array);
    print "The mean of the set is " . $mean->copy()->bround(5) . ".\n";
    return $mean;
}

#===  FUNCTION  ================================================================
#         NAME: sum
#   PARAMETERS: a list of numbers
#      RETURNS: the sum of the numbers in the list
#  DESCRIPTION: This function simply adds up all the numbers in a list. It then
#               returns this number.
#       THROWS: no exceptions
#===============================================================================
sub sum 
{
    my $total = Math::BigFloat->bzero();
    foreach (@_) {
        $total += $_->copy();
    }
    return $total;
}

#===  FUNCTION  ================================================================
#         NAME: mode
#   PARAMETERS: a list of numbers
#      RETURNS: the mode of the numbers in the list
#  DESCRIPTION: This function calculates the mode of the numbers in a list. It
#               does this by creating a hash and "adding" each number in the
#               list into the hash as a key and incrementing the value linked to
#               it by 1 thereby counting the number of occurances of each number
#               in the list. It then returns the number that appears the most as
#               well as printing it to STDOUT.
#       THROWS: no exceptions
#===============================================================================
sub mode 
{
    my %hash;
    my $highest = 0;
    my $highestNum = 0;
    foreach my $num (@_) {
        if(++$hash{$num} > $highest) {
            $highest = $hash{$num};
            $highestNum = $num;
        }
    }
    print "The mode of the set is $highestNum.\n";
    return $highestNum;
}

#===  FUNCTION  ================================================================
#         NAME: median
#   PARAMETERS: a list of numbers
#      RETURNS: the mediam of the numbers in the list
#  DESCRIPTION: This function calculates the median of the numbers in a list. It
#               does this by simply sorting the given list and returning the
#               middle element (length/2). It then returns this value as well as
#               printing it to STDOUT.
#       THROWS: no exceptions
#===============================================================================
sub median 
{
    my @sorted = sort {$a <=> $b} @_;
    my $size = @sorted;
    my $median;
    if($size == 1) {
        $median = $sorted[0];
        print "The median of the set is $median.\n";
        return $median;
    }
    elsif($size%2 == 0) {
        $median = ($sorted[$size/2] + $sorted[($size/2)-1])/2;
        print "The median of the set is $median.\n";
        return $median;
    }
    elsif($size%2 == 1) {
        $median = $sorted[floor($size/2)];
        print "The median of the set is $median.\n";
        return $median;
    }
    else {
        print "Empty Set.\n";
        return 0;
    }
}

#===  FUNCTION  ================================================================
#         NAME: standardDeviation
#   PARAMETERS: a list of numbers
#      RETURNS: the standard deviation of the numbers in the list
#  DESCRIPTION: This function calculates the standard deviation of the numbers
#               in a list. It assumes that the given list is the complete
#               population and is not a sample of a larger population. It
#               calculates the standard deviation by first getting the mean of
#               the list. It then calculates the sum of the squared difference
#               of the number and the mean. Finally it takes the square root of
#               this number which is the standard deviation. It then returns the
#               value in addition to printing it to STDOUT.
#       THROWS: no exceptions
#===============================================================================
sub standardDeviation 
{
    use Math::BigFloat;
    my @array = @_;
    my $size = Math::BigFloat->new(scalar(@array));
    my $mean = &mean(@array)->copy();
    my $sum = Math::BigFloat->bzero();
    my $sd = Math::BigFloat->bzero();
    foreach my $number (@array) {
        $sum += ($number - $mean)**2;
    }
    $sd = ($sum/$size)->copy()->bsqrt();
    print "The standard deviation of the set is " . $sd->copy()->bround(5) . ".\n";
    return $sd;
}

#===  FUNCTION  ================================================================
#         NAME: displayMenu
#   PARAMETERS: none
#      RETURNS: nothing
#  DESCRIPTION: This function displays the starting menu so that the code in the
#               main function is cleaner.
#       THROWS: no exceptions
#===============================================================================
sub displayMenu
{
    print "Please choose an option from the following menu by typing the corresponding number:\n";
    print "\t1. Parse a log file.\n";
    print "\t2. Create a new use account.\n";
    print "\t3. Add copyright information to a file.\n";
    print "\t4. List the contents of a directory.\n";
    print "\t5. Calculate statistics for numbers in a file.\n";
    print "\t6. Exit the program.\n";
    print "Your Choice: ";
}
