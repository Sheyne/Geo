use Ham::APRS::FAP qw(parseaprs);
my %packetdata;
my $retval = parseaprs(<STDIN>, \%packetdata);
if ($retval == 1) {
	print 'Callsign:',%packetdata->{'srccallsign'},"\n";
	print 'Latitude:',%packetdata->{'latitude'},"\n";
  	print 'Longitude:',%packetdata->{'longitude'},"\n";
	print 'Altitude:',%packetdata->{'altitude'},"\n";
} else {
	print "Parsing failed: $packetdata{resultmsg} ($packetdata{resultcode})\n";
}
#symbolcode: k
#body: /173809h3938.41N/10705.12Wk053/054/A=006177/k6ryd@arrl.net
#posresolution: 18.52
#timestamp: 1300469889
#speed: 100.008
#latitude: 39.6401666666667
#origpacket: K6RYD-9>APT311,SUNLGT,WIDE1,BLUEMT*,WIDE2-1:/173809h3938.41N/10705.12Wk053/054/A=006177/k6ryd@arrl.net
#srccallsign: K6RYD-9
#altitude: 1882.7496
#course: 53
#symboltable: /
#longitude: -107.085333333333
#dstcallsign: APT311
#digipeaters: ARRAY(0x1008b9558)
#comment: k6ryd@arrl.net
#format: uncompressed
#messaging: 0
#posambiguity: 0
#type: location
#header: K6RYD-9>APT311,SUNLGT,WIDE1,BLUEMT*,WIDE2-1
