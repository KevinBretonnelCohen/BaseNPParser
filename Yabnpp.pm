#!/usr/bin/perl

# Yet Another Base NP Parser

# actually, this one is different from the other boys--
# it will:
# 1) recognize GENE tags
# 2) try (later) to deal with coordination.

package Yabnpp;

use strict "vars";

# set to 1 for lots of helpful debugging output, or to "undef" to
# suppress same
my $debug = undef;
# my $debug = 1;

my @np_buffer;
# set this to 1 to produce yamcha-style output, or to undef to
# suppress same. yamcha-style output looks like this:
# the                     DT B-NP
# renin                   NEWGENE I-NP
# promoter                NEWGENE I-NP
# nCaRE                   NEWGENE I-NP
# ...i.e., each line contains one token (leftmost column),
# the POS or GENE tag (center column), and the phrasal tag
# (rightmost column).
my $show_yamcha_output = undef;


# set this to one to build an array of noun phrases to be 
# returned
my $return_an_array_of_nps = 1;

my @nps_to_return; # noun phrases to be returned

        #processSentence(@sentence_buffer);


#############################
## SUBROUTINE DEFINTITIONS ##
#############################

# the meat of the script
# input is an array of strings, each of which contains a 
# whitespace-delimited token/tag pair.  for example:
# The DT
# Krusty GENE
# gene GENE
# is VBZ
# associated VBN
# with IN
# high ADV
# rates NNS
# of IN
# seltzer NN
# metabolism NN
# . .
#
# output is all to STDOUT
sub processSentence {
    my (@input) = @_;

    $debug && print "in the processSentence() subroutine...\n";

    # see notes on revision 1.2 to see what interesting bug this
    # fixes.
    #@nps_to_return = undef;
    @nps_to_return = ();

    $" = "|";
    $debug && print "INPUT to processSentence: <@input>\n";
    # optionally, you might want to be able to display the
    # original generif....
    if (1) {
        my $id = $input[0];
        $id =~ s/\s.+$//;
        #print "$originals{$id}\n";
    }


    # you want to process the sentence from right to left, so 
    # the first step is to reverse the contents
    @input = reverse(@input);
    if ($debug) {
         print "reversed input: <@input>\n";
    }

    my @temp_np_buffer;

    # when you see a noun, the first question to ask is if it's
    # part of a new base np, or part of one that you're already
    # processing.  if it's a new one, the buffer will be empty.
    # if it's part of one that you're already processing, then
    # the buffer will be non-empty.
    foreach my $token_tag_pair (@input) {

        my ($token, $tag) = split (" ", $token_tag_pair);    
        if ($debug) {
            print "token: <$token> tag: <$tag>\n";
        }

        if (isANoun($tag)) {
            $debug && print "$token is a noun.\n";
            #if (isEmpty(@temp_np_buffer)) {}
            #push (@temp_np_buffer, $token_tag_pair);
            unshift(@temp_np_buffer, $token_tag_pair);
        } elsif (isLeftModifier($tag)) {
            if (isEmpty(@temp_np_buffer)) {
                # skip it, 'cause there's no NP to 
                # glom it onto
                next;
            } else {
                #push(@temp_np_buffer, $token_tag_pair);
                unshift(@temp_np_buffer, $token_tag_pair);
            }

        } else {
            # it's not a left modifier, so if you were
            # building an NP, then you've reached its 
            # left boundary; otherwise (i.e. if you weren't
            # building an NP), just go on
            if (isEmpty(@temp_np_buffer)) {
                next;
            } else {
                # emit an NP!
                $debug && print "here's an NP: <@temp_np_buffer>\n";
                if ($return_an_array_of_nps) {
                    $debug && print convertTokenTagPairsToStringOfTokens(@temp_np_buffer);
                    push (@nps_to_return, convertTokenTagPairsToStringOfTokens(@temp_np_buffer));
                    #print "\n";
                }
                @temp_np_buffer = tagThisNounPhrase(@temp_np_buffer);
                if ($show_yamcha_output) {
                    printLineByLine(@temp_np_buffer);
                }
                @temp_np_buffer = ();
            }
        }

    } # close foreach-loop through the sentence

    # ok, this is where the current Cohen bug is happening.
    # the issue is that i was relying on seeing something 
    # that's neither a noun nor a left modifier to know
    # when i was done building an NP.  thing is, if the NP
    # is at the left edge of the sentence, then you don't 
    # see any such indicator--you just run out of data
    # to process.
    if (isEmpty(@temp_np_buffer)) {
        #ext;
        # do nothing...
    } else {
        # emit an NP!
        $debug && print "here's an NP: <@temp_np_buffer>\n";
        if ($return_an_array_of_nps) {
            $debug && print convertTokenTagPairsToStringOfTokens(@temp_np_buffer);
            push (@nps_to_return, convertTokenTagPairsToStringOfTokens(@temp_np_buffer));
            #print "\n";
        }
        @temp_np_buffer = tagThisNounPhrase(@temp_np_buffer);
        if ($show_yamcha_output) {
            printLineByLine(@temp_np_buffer);
        }
        @temp_np_buffer = ();
    }

    # since you're processing the sentence from right to left,
    # you end up with your NP's in reverse order--let's switch
    # them back to the left-to-right order, for readability
    @nps_to_return = reverse(@nps_to_return);
    return(@nps_to_return);

} # close method def. processSentence()

sub isANoun {
    my ($tag) = @_;

    if ($tag eq "NN" ||
        $tag eq "NNS" || 
        $tag eq "NNP" ||
        $tag eq "NNPS" ||
        $tag eq "PP" ||
        $tag eq "PRP" ||
        $tag eq "NEWGENE" ||
        $tag eq "NEWGENE1") {
        return 1;
    } else {
        return undef;
    }
} # close method def. isANoun()

sub isEmpty {
    my (@input) = @_;
    if (@input) {
        return undef;
    } else {
        return 1;
    }
} # close method def. isEmpty()

sub isLeftModifier {
    my ($tag) = @_;
    if ($tag eq "CD" ||
        $tag eq "DT" ||
        $tag eq "JJ" ||
        $tag eq "JJR" ||
        $tag eq "JJS" ||
        $tag eq "PDT" ||
        $tag eq 'PP$') {
        return 1;
    } else {
        return undef;
    }
} # close method def. isLeftModifier()

# input: an array of strings, each of which is a 
# whitespace-separated token/tag pair,
# e.g. ("This DET", "dog NNS", "has VBZ" "fleas NPP", ". .").
# output: an array of strings containing the same strings,
# except with NP tags added.
sub tagThisNounPhrase {
    my (@inputs) = @_;

    $debug && print "in the tagThisNounPhrase subroutine...\n";

    # if there is just a single token/tag pair, tag it as
    # such.
    # if there are more then one pair, then tag the first
    # one as B and the remainder as I.
    if (@inputs == 1) {
        $inputs[0] .= " B-NP";
        return(@inputs);
    } elsif (@inputs > 1) {
        # do the first one--it's different from the rest
        $inputs[0] .= " B-NP";
        # now do the rest
        for (my $i = 1; $i < @inputs; $i++) {
            $inputs[$i] .= " I-NP";
        }
        return(@inputs);
    } else {
        # it's possible that an empty input list may have
        # snuck in somehow, in which case this will catch 
        # it.
        die "bad input to tagThisNounPhrase(): <@inputs>\n";
    }
    
} # close method def tagThisNounPhrase()

sub printLineByLine {
    my (@input) = @_;
    foreach my $line (@input) {
        print "$line\n";
    }
} # close method def. printLineByLine()

# input: an array of whitespace-separated token/tag
# pairs, e.g.
# ("Krusty NNPS", "The DT", "Klown NN")
# output: a single string containing just the
# tokens, e.g. 
# "Krusty The Klown"
sub convertTokenTagPairsToStringOfTokens {
    my (@input) = @_;
    
    $debug && print "in the convertTokenTagPairsEtc. subroutine...\n";

    my $output;
    foreach my $pair (@input) {
        my ($token, $tag) = split(" ", $pair);
        $output .= " " . $token;
    }
    $output =~ s/^ //;
    $output =~ s/ $//;
    return($output);
} # close method def. convertTokenTagEtc.()

# every Perl module needs to have this as its last line,
# presumably so that when it's loaded, it can return success
1;
