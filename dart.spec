
Name: dart
Release:        1%{?dist}
Summary:        Dart SDK
License:        BSD
URL:            https://dart.dev/
%define _build_id_links none
ExclusiveArch: %ix86 %arm64 %arm %x86_64 x86_64 %riscv64  riscv64
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

%define dartsource() Source%{1}: https://storage.googleapis.com/dart-archive/channels/dev/release/%{ver}/sdk/dartsdk-linux-%{2}-release.zip

%dartsource 0 x64
%dartsource 1 ia32
%dartsource 2 arm64
%dartsource 3 arm
%dartsource 4 riscv64

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
