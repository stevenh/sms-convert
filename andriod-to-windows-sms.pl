#!/usr/local/bin/perl -w

=head1 NAME

andriod-to-windows-sms.pl -- Converts SMS from Android to Windows Phone

=head1 SYNOPSIS

 cat sms.xml | ./andriod-to-windows-sms.pl > sms.vmsg

=head1 DESCRIPTION

Converts SMS exported from Android phones by Wondershare MobileGo
to Windows Phone format used by Transfer My Data.

=head1 AUTHOR

Steven Hartland <steven.hartland@multiplay.co.uk>

=head1 COPYRIGHT

Steven Hartland, 2016

=cut

use strict;
use Data::Dumper;
use MIME::QuotedPrint;
use HTML::Entities;

sub conv_body($)
{
	my $body = shift;

	# TODO(steve): support UTF-8
	my $enc = encode_qp(decode_entities($body));
	$enc =~ s/=\n$//s;

	return $enc;
}

sub conv_time($)
{
	my $time = shift;

	# 2015-07-18T23:13:56.439+01:00
	my ($year, $mon, $day, $hour, $min, $sec) = ($time =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/);

	return "$year/$mon/$day $hour:$min:$sec";
}

sub conv_box($)
{
	my $status = shift;

	if ($status == 3) {
		return 'SENDBOX';
	} elsif ($status == 2) {
		return 'INBOX';
	}

	print STDERR "Unknown status: $status\n";

	return 'INBOX';
}

sub output($)
{
	my $sms = shift;

	if ($sms->{'smstype'} != 0) {
		print STDERR "unsupported smstype: $sms->{'smstype'} (skipping)\n";
		print STDERR Dumper($sms);
		return;
	}

	my $body = conv_body($sms->{'body'});
	my $time = conv_time($sms->{'time'});
	my $box = conv_box($sms->{'status'});

	#print Dumper($sms);

	print <<__MSG__;
BEGIN:VMSG
VERSION: 1.1
BEGIN:VCARD
TEL:$sms->{'numbers'}
END:VCARD
BEGIN:VBODY
X-BOX:$box
X-READ:READ
X-SIMID:0
X-LOCKED:UNLOCKED
X-TYPE:SMS
Date:$time
Subject;ENCODING=QUOTED-PRINTABLE;CHARSET=UTF-8:$body
END:VBODY
END:VMSG
__MSG__
}

{
	my $start = 0;
	my $body;
	my %sms = ();
	while (<STDIN>) {
		if (/<Sms>/) {
			$start = 1;
		} elsif ($start) {
			if ( /<\/Sms>/) {
				$start = 0;
				output(\%sms);
				%sms = ();
			} elsif (defined $body) {
				if (/^(.*)<\/Body>/) {
					$body .= $1;
					$sms{'body'} = $body;
					$body = undef;
				} else {
					$body .= "$_\n";
				}
			} elsif (/<Id>(\d+)<\/Id>/) {
				$sms{'id'} = $1;
			} elsif (/<Numbers>(.*)<\/Numbers>/) {
				$sms{'numbers'} = $1;
			} elsif (/<Body>(.*)$/) {
				$_ = $1;
				if (/^(.*)<\/Body>/) {
					$sms{'body'} = $1;
				} else {
					$body = "$_\n";
				}
			} elsif (/<SmsType>(.*)<\/SmsType>/) {
				$sms{'smstype'} = $1;
			} elsif (/<Time>(.*)<\/Time>/) {
				$sms{'time'} = $1;
			} elsif (/<ThreadId>(.*)<\/ThreadId>/) {
				$sms{'threadid'} = $1;
			} elsif (/<Status>(.*)<\/Status>/) {
				$sms{'status'} = $1;
			} elsif (/<ChatType>(.*)<\/ChatType>/) {
				$sms{'chattype'} = $1;
			}
		}
	}
}
