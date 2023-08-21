use JSON::PP;
use LWP::Simple;

my @json = (
'/waydroid/lineage-vendor-mainline.arm64.zip'  , 'https://ota.waydro.id/vendor/waydroid_arm64/MAINLINE.json',
'/waydroid/lineage-vendor-mainline.arm.zip'    , 'https://ota.waydro.id/vendor/waydroid_arm/MAINLINE.json',
'/waydroid/lineage-vendor-mainline.x86_64.zip' , 'https://ota.waydro.id/vendor/waydroid_x86_64/MAINLINE.json',
'/waydroid/lineage-vendor-mainline.x86.zip'    , 'https://ota.waydro.id/vendor/waydroid_x86/MAINLINE.json',
'/waydroid/lineage-system-vanilla.arm64.zip'   , 'https://ota.waydro.id/system/lineage/waydroid_arm64/VANILLA.json',
'/waydroid/lineage-system-vanilla.arm.zip'     , 'https://ota.waydro.id/system/lineage/waydroid_arm/VANILLA.json',
'/waydroid/lineage-system-vanilla.x86_64.zip'  , 'https://ota.waydro.id/system/lineage/waydroid_x86_64/VANILLA.json',
'/waydroid/lineage-system-vanilla.x86.zip'     , 'https://ota.waydro.id/system/lineage/waydroid_x86/VANILLA.json'
);

open(my $fh, '>>', 'docs/_redirects');

my $ts = 0;

while ($#json) {
    my $resp = get(pop @json);
    my $json = decode_json($resp);
    my $temp = $json->{'response'}[0]{'datetime'};
    if ($temp > $ts){
        $ts = $temp;
    }
    my $url = $json->{'response'}[0]{'url'};
    print $fh (pop @json, ' ', $url, "\n");
}

close $fh;

my $version = POSIX::strftime("%m%d%Y", $ts);

open(my $fh, '>', 'waydroid_version');
print $fh ($version);
close $fh;
