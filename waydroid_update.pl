use JSON::PP;
use LWP::Simple;
use experimental "try";

my @txt = (
 'https://ota.waydro.id/system/lineage/waydroid_x86_64/VANILLA.json',
 'https://ota.waydro.id/vendor/waydroid_x86_64/MAINLINE.json',
 'https://ota.waydro.id/system/lineage/waydroid_arm/VANILLA.json',
 'https://ota.waydro.id/vendor/waydroid_arm/MAINLINE.json',
 
 'https://ota.waydro.id/system/lineage/waydroid_arm64/VANILLA.json',
 'https://ota.waydro.id/vendor/waydroid_arm64/MAINLINE.json',
 'https://ota.waydro.id/system/lineage/waydroid_x86/VANILLA.json',
 'https://ota.waydro.id/vendor/waydroid_x86/MAINLINE.json'
);

open(my $fh, '>', 'docs/waydroid-image.spec');
print $fh 'Name:           waydroid-image
Release:        0
Summary:        Waydroid is a container-based approach to boot a full Android
License:        LGPL-3.0-only
URL:            https://github.com/waydroid/waydroid
';

my $ts = 0;
my $id = 0;
my @urls=();
my @names=();
my @jsons=();

for my $t (@txt) {
    my $resp = get($t);
    my $json = decode_json($resp);
    push @jsons, $json;
    my $url = $json->{'response'}[0]{'url'};
    push @urls, $url;
    my $name = $json->{'response'}[0]{'filename'};
    push @names, $name;
    my $temp = $json->{'response'}[0]{'datetime'} + 0;
    if ($temp > $ts){
        $ts = $temp;
    }
}

for my $t (@urls){
    my $n = $names[$id];
    print $fh "Source$id: $t#/$n\n";
    $id++;
}

my $version =  'Version: ' . POSIX::strftime("%Y%m%d", localtime($ts));

print $fh "$version\n";

print $fh '
%if %{undefined arm64}
%define arm64 aarch64
%endif

%if %{undefined x86_64}
%define x86_64 x86_64 amd64
%endif

%ifarch %x86_64
%define wayarch x86_64
%define waynum0 0
%define waynum1 1
%elifarch %arm
%define wayarch arm
%define waynum0 2
%define waynum1 3
%elifarch %arm64
%define wayarch arm64
%define waynum0 4
%define waynum1 5
%elifarch %ix86
%define wayarch x86
%define waynum0 6
%define waynum1 7
%endif

ExclusiveArch: %ix86 %arm64 %arm %x86_64 

BuildRequires:  unzip 
BuildRequires:  rpm_macro(find_waydroid_extra_provides)
Requires:       waydroid
Conflicts:      waydroid-image

%find_waydroid_extra_provides


%description
Waydroid is a container-based approach to boot a full Android system on a regular GNU/Linux system.

%prep

%setup -q -c -T -a %{waynum0} -a %{waynum1}


%build

%install
install -dm755 %{buildroot}%{_datadir}/waydroid-extra/images
mv system.img %{buildroot}%{_datadir}/waydroid-extra/images
mv vendor.img %{buildroot}%{_datadir}/waydroid-extra/images

%files
%dir %{_datadir}/waydroid-extra
%{_datadir}/waydroid-extra/images
%{_datadir}/waydroid-extra/images/system.img
%{_datadir}/waydroid-extra/images/vendor.img

';


close $fh;

