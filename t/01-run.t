package Some;
use 5.006;
use strict;
use warnings;
use Test::More;
use lib 'lib';
use lib 'fakelib2';
use lib 'fakelib';

BEGIN {
    use_ok( 'Submodules', 'walk' ) || print "Bail out!\n";
}

my @expected = qw(
	Some
	Some::Module
	Some::More
	Some::Xtras
	Some::Module::Functions
	Some::Module::Methods
	Some
	Some::Module
	Some::More
	Some::Xtras
	Some::Module::Functions
	Some::Module::Methods
);
my @found;
my @found2;

for my $i (Submodules->find) {
	die "I got something that is not a Submodules::Result object" unless ref($i) eq 'Submodules::Result';
	next unless $i->{RelPath} =~ /fakelib/;
	push @found, $i;
}

for my $i (walk Some) {
	die "I got something that is not a Submodules::Result object" unless ref($i) eq 'Submodules::Result';
	next unless $i->{RelPath} =~ /fakelib/;
	push @found2, $i;
}

for (my $n = 0; $n < @found2; $n++) {
	is "$found2[$n]", "$found[$n]", 'Method find and created "walk" function got the same results';
}

for (my $n = 0; $n < @found; $n++) {
	my $i = $found[$n];
	is "$i", $expected[$n], "$i as expected";
	is ref($i), 'Submodules::Result', qq[$i is a Submodules::Result object];
	if ($n >= 6) {
		is $i->Clobber, $found[$n - 6]->AbsPath, "$i->{RelPath} is clobbered as expected by $found[$n - 6]->{AbsPath}";
	}
	unless ($i->Clobber) {
		no strict 'refs';
		is $i->require, 1, "Require-ing $i";
		is ${"${i}::IMPORTED"}, undef, "Require won't call import";
		is $i->use, 1, "Use-ing $i";
		is ${"${i}::IMPORTED"}, 1, "Use will call import";
		is ${"${i}::COUNT"}, 1, "Content won't execute twice";
		is ${"${i}::VERSION"}, '1.0', "$i version is correct";
		is "$i"->package, "$i", "'package' method returned correct response";
	}
}

done_testing;

