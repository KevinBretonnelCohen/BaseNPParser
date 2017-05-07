#!/usr/bin/perl

use strict "vars";

use Yabnpp;

my @sentences;

@sentences = (["The DT", "Krusty NEWGENE", 
"gene NEWGENE", "is VBZ", 
"associated VBN", "with IN", "high JJ", 
"rates NNS", "of IN", "seltzer NN",
"metabolism NN", ". "],
["It			PRP",
"is			VBZ",
"unlikely		JJ",
"that			IN",
"the			DT",
"NAT1*10			NEWGENE",
"or			CC",
"NAT2			NEWGENE",
"rapid/intermediate	VB",
"genotypes		NNS",
"are			VBP",
"related			VBN",
"to			IN",
"stomach			NN",
"cancer			NN",
"risk			NN",
 ".			."],
["Helical			NNP",
"apolipoproteins		NEWGENE",
"stabilize		VB",
"ATP-binding		NEWGENE",
"cassette		NEWGENE",
"transporter		NEWGENE",
"A1			NEWGENE",
"by			IN",
"protecting		JJ",
"it			PRP",
"from			IN",
"thiol			NN",
"protease-mediated	JJ",
"degradation		NN",
".			."
],


);

#@nps = Yabnpp::processSentence(("The DT", "Krusty NEWGENE", 
#"gene NEWGENE", "is VBZ", 
#"associated VBN", "with IN", "high JJ", 
#"rates NNS", "of IN", "seltzer NN",
#"metabolism NN", ". "));

foreach my $sentence_ref (@sentences) {
    my @sentence = @$sentence_ref;
    my @nps = Yabnpp::processSentence(@sentence);
    print "@nps\n";
}

("It			PRP",
"is			VBZ",
"unlikely		JJ",
"that			IN",
"the			DT",
"NAT1*10			NEWGENE",
"or			CC",
"NAT2			NEWGENE",
"rapid/intermediate	VB",
"genotypes		NNS",
"are			VBP",
"related			VBN",
"to			IN",
"stomach			NN",
"cancer			NN",
"risk			NN",
 ".			.",);


