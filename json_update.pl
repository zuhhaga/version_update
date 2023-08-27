use JSON::PP;
use LWP::Simple;
use experimental "try";

sub addtext{
    my $fh = shift;
    my $path = shift;
    my $input;
    open($input, '<', $path);
    while (<$input>){
        print $fh $_;
    }
    close $input;
}

sub waysys{
    my $arch = shift;
    my $var = shift;
    return "https://ota.waydro.id/system/lineage/waydroid_$arch/$var.json";
}

sub wayven{
    my $arch = shift;
    my $var = shift;
    return "https://ota.waydro.id/vendor/waydroid_$arch/$var.json";
}

my @txt = ();
my @archs = (qw( x86_64 arm arm64 x86 ));

for (@archs){
    push @txt, waysys($_, 'VANILLA');
    push @txt, wayven($_, 'MAINLINE');
}


my %jsons;

my $packagename = 'waydroid-image';

label1: 
open(my $fh, '>', "docs/$packagename.spec");

my $ts = 0;
my @urls=();
my @names=();
my $resp;
my $json;
my $url;
my $name;
my $temp;

for (@txt) {
    $json = $jsons{$_};
    if (not defined($json)){
        $resp = get($_);
        $json = decode_json($resp);
        $jsons{$_} = $json;
    }
    $url = $json->{'response'}[0]{'url'};
    push @urls, $url;
    $name = $json->{'response'}[0]{'filename'};
    push @names, $name;
    $temp = $json->{'response'}[0]{'datetime'} + 0;
    if ($temp > $ts){
        $ts = $temp;
    }
}

my $version = POSIX::strftime("%Y%m%d", localtime($ts));
print $fh "Name: $packagename
Version: $version
";


my $id = 0;
while ($id < 8){
    my $n = $names[$id];
    my $t = $urls[$id];
    print $fh "Source$id: $t#/$n\n";
    $id++;
}

addtext($fh, 'waydroid-image.spec');

close $fh;

if ($packagename eq 'waydroid-image'){
    $packagename = 'waydroid-image-gapps';
    $id = 0;
    for (@archs){
        $txt[$id] = waysys($_, 'GAPPS');
        $id = $id + 2;
    }
    goto label1;
}




$resp = get('https://storage.googleapis.com/dart-archive/channels/dev/release/latest/VERSION');


$json = decode_json($resp);

my @x = split(/-/, $json->{'version'});

open($fh, '>', 'docs/dart.spec');

print $fh 'Version: ' . $x[0] . "\n";
print $fh '%define ver %{version}-' . $x[1];
#-' . $x[1] . "\n";


addtext($fh, 'dart.spec');

close $fh;










