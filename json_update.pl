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
my $resp;
my $json;
my $url;
my $name;
my $temp;

for my $t (@txt) {
    $resp = get($t);
    $json = decode_json($resp);
    push @jsons, $json;
    $url = $json->{'response'}[0]{'url'};
    push @urls, $url;
    $name = $json->{'response'}[0]{'filename'};
    push @names, $name;
    $temp = $json->{'response'}[0]{'datetime'} + 0;
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


$resp = get('https://storage.googleapis.com/dart-archive/channels/dev/release/latest/VERSION');


$json = decode_json($resp);

my @x = split(/-/, $json->{'version'});

open($fh, '>', 'docs/dart.spec');

print $fh "Name: dart\n";
print $fh 'Version: ' . $x[0] . "\n";
print $fh '%define ver %{version}-' . $x[1] . "\n";
print $fh <<'EOF';
Release:        1%{?dist}
Summary:        Dart SDK
License:        BSD
URL:            https://dart.dev/
%define _build_id_links none
ExclusiveArch: %ix86 %arm64 %arm %x86_64 %riscv64 x86_64 riscv64
%define alternatives (update-alternatives or alternatives)
%ifarch %{x86_64} x86_64
%define dartarch x64
%define dartnum 0
%elifarch %{ix86}
%define dartarch ia32
%define dartnum 1
%elifarch %{arm64} aarch64
%define dartarch arm64
%define dartnum 2
%elifarch %{arm}
%define dartarch arm
%define dartnum 3
%elifarch %{riscv64} riscv64 
%define dartarch riscv64
%define dartnum 4
%endif

%define dartpath %{_usr}/lib/dart-sdk-%{version}-%{dartarch}

%define dartsource() Source%{1}: https://storage.googleapis.com/dart-archive/channels/stable/release/%{ver}/sdk/dartsdk-linux-%{2}-release.zip

%dartsource 0 x64
%dartsource 1 ia32
%dartsource 2 arm64
%dartsource 3 arm
%dartsource 4 riscv64
#Source0:        https://storage.googleapis.com/dart-archive/channels/stable/release/%{ver}/sdk/dartsdk-linux-%{dartarch}-release.zip

BuildRequires: unzip
BuildRequires: coreutils

Requires(post):    %alternatives
Requires(postun):  %alternatives

%post
%{_sbindir}/update-alternatives --install '%{_usr}/lib/dart-sdk' dart-sdk '%{dartpath}' 25
%{_sbindir}/update-alternatives --install '%{_bindir}/dart' dart '%{dartpath}/bin/dart' 25
%{_sbindir}/update-alternatives --install '%{_bindir}/dartaotruntime' dartaotruntime '%{dartpath}/bin/dartaotruntime' 25 || :

%postun
%{_sbindir}/update-alternatives --remove dartaotruntime '%{dartpath}/bin/dartaotruntime' || : 
%{_sbindir}/update-alternatives --remove dart '%{dartpath}/bin/dart' || : 
%{_sbindir}/update-alternatives --remove dart-sdk '%{dartpath}' || : 


%description
The Dart SDK has the libraries and command-line tools that you need to develop Dart web, command-line, and server apps.

%prep
%autosetup -T -b %{dartnum} -n dart-sdk

%install
mkdir -p '%{buildroot}%{_usr}/lib'
cp -prT ../dart-sdk '%{buildroot}%{dartpath}'

%files
%{dartpath}
EOF

close $fh;










