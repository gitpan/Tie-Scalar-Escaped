package Tie::Scalar::Escaped;

use strict;
use warnings;

use vars qw/$VERSION %uppercase/;


$VERSION = '0.01';

sub TIESCALAR{
	shift; #lose package name
	my $var = shift;
	bless \$var;
};

sub FETCH{
	my $tmp = ${$_[0]};
	$tmp =~ s/%/%%/g;
	$tmp =~ s/([^%A-Za-z0-9])/'%'.ord($1).'%'/ge;
	$tmp =~ s/([A-Z])/'%'.lc($1)/ge;
	$tmp;
};

sub STORE{
	${$_[0]} = $_[1];

};

sub unescape($){
	my $tmp = shift;

	$tmp =~ s/%(\d+)%/chr $1/ge;
	$tmp =~ s/%([a-z])/uc $1/ge;
	$tmp =~ s/%%/%/g;
	
	$tmp;
}

sub import{
	if (grep {$_ eq 'unescape'} @_){
		*{caller().'::unescape'} = \&unescape;
	};
};

1;
__END__

=head1 NAME

Tie::Scalar::Escaped - a variable that gives you a safe value

=head1 SYNOPSIS

  use Tie::Scalar::Escaped;
  tie $filename <= Tie::Scalar::Escaped;
  $filename = "MultiCase <and extended>";
  open HANDLE, ">$filename" or die "$!";
  # the previous line opens %multi%case%32%%60%and%32%extended%62%

=head1 DESCRIPTION


At FETCH time, some transformations are performed
on the data in the scalar so it is expanded to only
include characters in [0-9a-z%].  Upper case chars
are preceded by a % and everything else is expanded
into \%NN where NN is the ord of the character. % characters
are doubled.

After tieing C<$e> to C<Tie::Scalar::Escaped>,
C<${tied $e}> and  C<Tie::Scalar::Escaped::unescape($e)>
are equivalent.


=head1 EXPORTS

an C<unescape> function is provided to wrestle the escaped
strings back into binary form, if needed

=head1 PLANS

=over 4

=item better casing

internationalization may be weak, esp. in case issues.  C<uc> and C<lc>
are used for recasing, but the ranges are in terms of [A-Z] and [a-z]
instead of the defined character classes for these things. 

=item configurable escaping character

this module uses percentage-sign and there isn't a way to tell it
to use something else.

=back

=head1 HISTORY

=over 8

=item 0.01 20 May 2003

Original version, created to support a propsed patch to L<perlvar>

=back


=head1 AUTHOR

David Nicol, E<lt>davidnico@cpan.orgE<gt>

=cut
