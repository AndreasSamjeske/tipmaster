#!/usr/bin/perl

=head1 NAME
	TMDao.pm

=head1 SYNOPSIS
	TM DAO
	
=head1 Author
	Thomas (thomas@socapro.com)

=head1 COPYRIGHT
	Copyright SocaPro Inc
	Created Jun 15, 2015
	
=cut

package TMDao;

use lib '/tmapp/tmsrc/cgi-bin/';
use lib '/tmapp/tmsrc/cgi-mod/';

use TMConfig;
use TMAuthenticationController;
use TMLogger;

sub getUserForEmail {

	my $email = shift;
	my @lines = @{ _getPasswordLines() };

	foreach (@lines) {
		my @data = split( /&/, $_ );
		return $data[1] if ( lc $data[3] eq lc $email );
	}
	return undef;

}

sub getHashedPasswordForUser {

	my $user  = shift;
	my @lines = @{ _getPasswordLines() };

	foreach (@lines) {
		my @data = split( /&/, $_ );
		return $data[2] if ( lc $data[1] eq lc $user );
	}
	return undef;

}

sub updatePasswordForUser {
	my $password = shift;
	my $user     = shift;
	
	my $hashedPassword = TMAuthenticationController::hashPassword( $password, $user );

	my @lines = @{ _getPasswordLines() };
	my $output;
	foreach (@lines) {
		my @data = split( /&/, $_ );
		if ( $data[1] eq $user ) {
			$output .= '!&' . $user . '&' . $hashedPassword . '&' . $data[3] . '&' . "\n";
		}
		else {
			$output .= $_;
		}
	}

	my @lines         = ();
	my $inputFilePath = $TMConfig::FILE_PATH_PASS;
	my $inputFile     = IO::File->new("> $inputFilePath");
	binmode( $inputFile, ":encoding(UTF-8)" );
	$inputFile->write($output);
	$inputFile->close();

}

sub createNewPasswordForUser {
	my $user        = shift;
	my $newPassword = _createRandomPassword();
	updatePasswordForUser( $newPassword, $user );
	return $newPassword;
}

sub _getPasswordLines {
	my $inputFilePath = $TMConfig::FILE_PATH_PASS;
	my $inputFile = IO::File->new( $inputFilePath, "r" );
	binmode( $inputFile, ":encoding(UTF-8)" );
	@lines = $inputFile->getlines();
	$inputFile->close();
	return \@lines;
}

sub _createRandomPassword {
	my $length   = 10;
	my $possible = 'abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
	while ( length($password) < $length ) {
		$password .= substr( $possible, ( int( rand( length($possible) ) ) ), 1 );
	}
	return $password;
}
1;
