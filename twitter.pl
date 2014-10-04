use Net::Twitter;
use Net::Twitter::Search;
use Win32::TieRegistry(Delimiter => '/');
use Date::Parse;
use open ':std', ':encoding(UTF-8)';

my $app_key = "xxxxxxxxxxxx";
my $app_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
my $t_cmd = ""; # Twitter command
my $t_text = ""; # text
my $t_user = ""; # screen name
my $t_count = 20; # amount of results to return
my $t_login = 0; # force login;
my $t_lang = "en"; # default language
my $t_debug = "0"; # debug

print "CmdLineTwitter v1.0 - Patrick Lambert [http://dendory.net]\n\n";

my $cfg = $Registry->{"HKEY_CURRENT_USER/Software/CmdLineTwitter/"} or do
{
	$Registry->{"HKEY_CURRENT_USER/Software/CmdLineTwitter/"} = {};
	$cfg = $Registry->{"HKEY_CURRENT_USER/Software/CmdLineTwitter/"} or do
	{
		t_error("Could not access Registry.");
	};
};

if($ARGV[0] eq "-timeline" || $ARGV[0] eq "-t")
{
	$t_cmd = "timeline";
	$t_count = int($ARGV[1]);
	if($t_count < 1 || $t_count > 200) { $t_count = 20; }
}
elsif($ARGV[0] eq "-post" || $ARGV[0] eq "-p")
{
	$t_cmd = "update";
	shift(@ARGV);
	$t_text = join(" ", @ARGV);
	if($t_text eq "") { t_error("Text required."); }
}
elsif($ARGV[0] eq "-message" || $ARGV[0] eq "-m")
{
	$t_cmd = "message";
	shift(@ARGV);
	$t_user = $ARGV[0];
	shift(@ARGV);
	$t_text = join(" ", @ARGV);
	if($t_user eq "") { t_error("User required."); }
	if($t_text eq "") { t_error("Text required."); }
}
elsif($ARGV[0] eq "-search" || $ARGV[0] eq "-s")
{
	$t_cmd = "popular";
	shift(@ARGV);
	$t_text = join(" ", @ARGV);
	if($t_text eq "") { t_error("Text required."); }
}
elsif($ARGV[0] eq "-recent" || $ARGV[0] eq "-r")
{
	$t_cmd = "recent";
	shift(@ARGV);
	$t_text = join(" ", @ARGV);
	if($t_text eq "") { t_error("Text required."); }
}
elsif($ARGV[0] eq "-follow" || $ARGV[0] eq "-f")
{
	$t_cmd = "follow";
	shift(@ARGV);
	$t_user = $ARGV[0];
	if($t_user eq "") { t_error("User required."); }
}
elsif($ARGV[0] eq "-unfollow" || $ARGV[0] eq "-u")
{
	$t_cmd = "unfollow";
	shift(@ARGV);
	$t_user = $ARGV[0];
	if($t_user eq "") { t_error("User required."); }
}
elsif($ARGV[0] eq "-inbox" || $ARGV[0] eq "-i")
{
	$t_cmd = "inbox";
	$t_count = int($ARGV[1]);
	if($t_count < 1 || $t_count > 200) { $t_count = 20; }
}
elsif($ARGV[0] eq "-retweets" || $ARGV[0] eq "-x")
{
	$t_cmd = "retweets";
	$t_count = int($ARGV[1]);
	if($t_count < 1 || $t_count > 200) { $t_count = 20; }
}
elsif($ARGV[0] eq "-mentions" || $ARGV[0] eq "-z")
{
	$t_cmd = "mentions";
	$t_count = int($ARGV[1]);
	if($t_count < 1 || $t_count > 200) { $t_count = 20; }
}
elsif($ARGV[0] eq "-user" || $ARGV[0] eq "-e")
{
	$t_cmd = "user";
	$t_user = int($ARGV[1]);
	if($t_user eq "") { t_error("User required."); }
}
elsif($ARGV[0] eq "-logout")
{
	$cfg->{'token'} = "." or do
	{
		t_error("Could not save token to Registry.");
	};
	$cfg->{'secret'} = "." or do
	{
		t_error("Could not save token to Registry.");
	};
	$t_login = 1;
	exit 0;
}
elsif($ARGV[0] eq "-lang")
{
	$cfg->{'lang'} = $ARGV[1] or do
	{
		t_error("Could not save token to Registry.");
	};
	exit 0;
}
elsif($ARGV[0] eq "-debug")
{
	$cfg->{'debug'} = "1" or do
	{
		t_error("Could not save token to Registry.");
	};
	exit 0;
}
elsif($ARGV[0] eq "-login")
{
	$t_login = 1;
}
else
{
	print "Usage:\n$0\t-t|-timeline [count]\n$0\t-p|-post <text>\n$0\t-i|-inbox [count]\n$0\t-m|-message <user> <text>\n$0\t-f|-follow <user>\n$0\t-u|-unfollow <user>\n$0\t-e|-user <user>\n$0\t-s|-search <text>\n$0\t-r|-recent <text>\n$0\t-x|-retweets [count]\n$0\t-z|-mentions [count]\n$0\t-lang <language>\n$0\t-debug\n$0\t-login\n$0\t-logout\n\n";
	exit 1;
}

my $access_token = $cfg->{'token'};
my $access_token_secret = $cfg->{'secret'} or $access_token_secret = "hello";
$t_lang = $cfg->{'lang'} or $t_lang = "en";
$t_debug = $cfg->{'debug'} or $t_debug = "0";

if($access_token eq "") {$access_token = "hello";}    # wow Net::Twitter is badly coded.. can't accept an empty string
if($access_token_secret eq "") {$access_token_secret = "hello";}

my $nt;
if($access_token eq "" || $access_token_secret eq "" || $access_token eq "." || $access_token_secret eq "." || $t_login)
{
	eval { $nt = Net::Twitter->new(traits => [qw/API::RESTv1_1 OAuth/], consumer_key => $app_key, consumer_secret => $app_secret, ssl => 1); } or t_error("Could not connect to Twitter.");
}
else
{
	eval { $nt = Net::Twitter->new(traits => [qw/API::RESTv1_1 OAuth/], consumer_key => $app_key, consumer_secret => $app_secret, access_token => $access_token, access_token_secret => $access_token_secret, ssl => 1); } or t_error("Could not connect to Twitter.");
}

if(!$nt->authorized || $t_login)
{
	eval { print "You must authorize this app at ", $nt->get_authorization_url, " and enter the PIN below.\n\nPIN: "; } or t_error("Unexpected API error. Try again later. If it keeps happening, try -logout and -login.");
	my $pin = <STDIN>;
	chomp $pin;
	($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);
	$cfg->{'token'} = $access_token or do
	{
		t_error("Could not save token to Registry.");
	};
	$cfg->{'secret'} = $access_token_secret or do
	{
		t_error("Could not save token to Registry.");
	};
}

my $info;
eval { $info = $nt->account_settings(); } or t_error("Could not fetch user information. Try -login.");

print "Logged in as \@@$info{'screen_name'}\n\n";

if($t_cmd eq "timeline")
{
	my $timeline, @results;
	eval {$timeline = $nt->home_timeline({count => $t_count});} or t_error("Failed to fetch timeline.");
	foreach my $list(@{$timeline})
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(str2time($list->{created_at}));
		$year += 1900;
		$mon += 1;
		$rmin = sprintf("%02d", $min);
		if($list->{retweet_count} > 0) { push(@results, "[$hour:$rmin \@$list->{user}{screen_name} x$list->{retweet_count}] $list->{text}\n\n"); }
		else { push(@results, "[$hour:$rmin \@$list->{user}{screen_name}] $list->{text}\n\n"); }
	}
	foreach $result (reverse(@results)) { print $result; }
}
elsif($t_cmd eq "update")
{
	eval { $nt->update($t_text); } or t_error("Failed to post.");
	print("Posted [$t_text]\n");
}
elsif($t_cmd eq "message")
{
	eval { $nt->new_direct_message({text => $t_text, screen_name => $t_user}); } or t_error("Failed to send direct message.");
	print("Sent [$t_text] to [$t_user]\n");
}
elsif($t_cmd eq "follow")
{
	eval { $nt->create_friend($t_user); } or t_error("Failed to add friend.");
	print("Added friend [$t_user]\n");
}
elsif($t_cmd eq "unfollow")
{
	eval { $nt->destroy_friend($t_user); } or t_error("Failed to remove friend.");
	print("Removed friend [$t_user]\n");
}
elsif($t_cmd eq "recent" || $t_cmd eq "popular")
{
	my $sresults, @results;
	eval { $sresults = $nt->search({q => $t_text, lang => $t_lang, result_type => $t_cmd, count => "30"}); } or t_error("Search failed.");
	foreach my $r (@{$sresults->{statuses}})
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(str2time($r->{created_at}));
		$year += 1900;
		$mon += 1;
		$rmin = sprintf("%02d", $min);
		if($r->{retweet_count} > 0) { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name} x$r->{retweet_count}] $r->{text}\n\n"); }
		else { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name}] $r->{text}\n\n"); }
	}
	foreach $result (reverse(@results)) { print $result; }
}
elsif($t_cmd eq "mentions")
{
	my $sresults, @results;
	eval { $sresults = $nt->mentions({count => $t_count, lang => $t_lang}); } or t_error("Failed to fetch mentions.");
	foreach my $r (@{$sresults})
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(str2time($r->{created_at}));
		$year += 1900;
		$mon += 1;
		$rmin = sprintf("%02d", $min);
		if($r->{retweet_count} > 0) { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name} x$r->{retweet_count}] $r->{text}\n\n"); }
		else { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name}] $r->{text}\n\n"); }
	}
	foreach $result (reverse(@results)) { print $result; }
}
elsif($t_cmd eq "retweets")
{
	my $sresults, @results;
	eval { $sresults = $nt->retweets_of_me({count => $t_count, lang => $t_lang}); } or t_error("Failed to fetch retweets.");
	foreach my $r (@{$sresults})
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(str2time($r->{created_at}));
		$year += 1900;
		$mon += 1;
		$rmin = sprintf("%02d", $min);
		if($r->{retweet_count} > 0) { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name} x$r->{retweet_count}] $r->{text}\n\n"); }
		else { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name}] $r->{text}\n\n"); }
	}
	foreach $result (reverse(@results)) { print $result; }
}
elsif($t_cmd eq "user")
{
	my $sresults, @results;
	eval { $sresults = $nt->user_timeline({count => $t_count, lang => $t_lang, screen_name => $t_user}); } or t_error("Failed to fetch tweets.");
	foreach my $r (@{$sresults})
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(str2time($r->{created_at}));
		$year += 1900;
		$mon += 1;
		$rmin = sprintf("%02d", $min);
		if($r->{retweet_count} > 0) { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name} x$r->{retweet_count}] $r->{text}\n\n"); }
		else { push(@results, "[$year-$mon-$mday $hour:$rmin \@$r->{user}{screen_name}] $r->{text}\n\n"); }
	}
	foreach $result (reverse(@results)) { print $result; }
}
elsif($t_cmd eq "inbox")
{
	my $inbox, @results;
	eval { $inbox = $nt->direct_messages({count => $t_count, lang => $t_lang}); } or t_error("Failed to fetch inbox.");
	foreach my $im(@{$inbox})
	{
		($sec,$min,$hour,$mday,$mon,$year) = localtime(str2time($im->{created_at}));
		$year += 1900;
		$mon += 1;
		$rmin = sprintf("%02d", $min);
		push(@results, "[$year-$mon-$mday $hour:$rmin \@$im->{sender_screen_name}] $im->{text}\n\n");
	}
	foreach $result (reverse(@results)) { print $result; }
}

exit 0;

sub t_error()
{
	if(index($@, "Rate limit") != -1)
	{
		print "Error: Rate limit reached.";
		exit 1;
	}
	if($t_debug eq "0") { print "Error: @_\n"; }
	else { print "Error: @_ [$@]\n"; }
	exit 1;
}