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

# update waydroid version
my @jsons=();

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

my $fh;
my @archs = (qw( x86_64 arm arm64 x86 ));

my @arrsys=qw(GAPPS VANILLA);
my @arrven=qw(MAINLINE);

my $hash_arr = {
    'vendor' => \@arrven,
    'system' => \@arrsys
};

my $hash_way = {
    'vendor' => \&wayven,
    'system' => \&waysys
};

for my $con ("vendor", "system"){
    my $arr = $$hash_arr{$con};
    my $way = $$hash_way{$con};
    for (@$arr){
        my $temp = lc $_;
        my $var = $_;
        my $fh;
        open($fh, '>', "docs/waydroid-image-$con-$temp.spec");
        my $i = 0;
        my $ver = 0;
        while ($i < 4){
            my $arch = $archs[$i];
            my $jsonurl = &$way($arch, $var);
            print($jsonurl);
            my $resp = get($jsonurl);
            print("\n");
#            print($resp);
            my $json = decode_json($resp);
            push @jsons, $json;
            
            my $url = $json->{'response'}[0]{'url'};
            my $name = $json->{'response'}[0]{'filename'};
            my $temp = $json->{'response'}[0]{'datetime'} + 0;
            
            print $fh "Source$i: $url/#$name\n";
            if ($temp > $ver) { $ver = $temp; };
            $i = $i + 1;
        }
        
        my $ver = POSIX::strftime("%Y%m%d", localtime($ver));
        print $fh "Version: $ver\n%define type $con\n";
        addtext($fh, "waydroid-image.spec");
        close $fh;
    }
}


#for (@arrsys){
#    my $temp = lc $_;
#    open($fh, '>', "docs/waydroid-image-system-${temp}.spec");
    
#        my $resp = get($_);
#        my $json = decode_json($resp);
#        push @jsons, $json;
#}
#for (@archs){
#    push @txt, waysys($_, 'GAPPS');
#    push @txt, waysys($_, 'VANILLA');
#    push @txt, wayven($_, 'MAINLINE');
#}

#$url = $json->{'response'}[0]{'url'};
#push @urls, $url;
#$name = $json->{'response'}[0]{'filename'};
#push @names, $name;
#$temp = $json->{'response'}[0]{'datetime'} + 0;

#my $packagename = 'waydroid-image';

#label1: 
#open(my $fh, '>', "docs/$packagename.spec");


# update dart sdk version

$resp = get('https://storage.googleapis.com/dart-archive/channels/beta/release/latest/VERSION');


$json = decode_json($resp);

my @x = split(/-/, $json->{'version'});

open($fh, '>', 'docs/dart.spec');

print $fh 'Version: ' . $x[0] . "\n";
print $fh '%define ver %{version}-' . $x[1] . "\n";


addtext($fh, 'dart.spec');

close $fh;










