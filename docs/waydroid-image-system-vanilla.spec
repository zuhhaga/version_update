Source0: https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_x86_64/lineage-18.1-20230916-VANILLA-waydroid_x86_64-system.zip/download/#lineage-18.1-20230916-VANILLA-waydroid_x86_64-system.zip
Source1: https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_arm/lineage-18.1-20230916-VANILLA-waydroid_arm-system.zip/download/#lineage-18.1-20230916-VANILLA-waydroid_arm-system.zip
Source2: https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_arm64/lineage-18.1-20230916-VANILLA-waydroid_arm64-system.zip/download/#lineage-18.1-20230916-VANILLA-waydroid_arm64-system.zip
Source3: https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_x86/lineage-18.1-20230916-VANILLA-waydroid_x86-system.zip/download/#lineage-18.1-20230916-VANILLA-waydroid_x86-system.zip
Version: 20230916
%define type system
Release:        0
Summary:        Waydroid is a container-based approach to boot a full Android
License:        LGPL-3.0-only
URL:            https://github.com/waydroid/waydroid


%if %{undefined arm64}
%define arm64 aarch64
%endif

%if %{undefined x86_64}
%define x86_64 x86_64 amd64
%endif

%ifarch %x86_64
%define wayarch x86_64
%define waynum0 0
%elifarch %arm
%define wayarch arm
%define waynum0 1
%elifarch %arm64
%define wayarch arm64
%define waynum0 2
%elifarch %ix86
%define wayarch x86
%define waynum0 3
%endif

ExclusiveArch: %ix86 %arm64 %arm %x86_64 

BuildRequires:  unzip 
BuildRequires:  rpm_macro(find_waydroid_extra_provides)
Requires:       waydroid
Provides:       waydroid-image-%{type}
Conflicts:      waydroid-image-%{type}

%find_waydroid_extra_provides


%description
Waydroid is a container-based approach to boot a full Android system on a regular GNU/Linux system.

%prep

%setup -q -c -T -a %{waynum0} 


%build

%install
install -dm755 %{buildroot}%{_datadir}/waydroid-extra/images
mv %{type}.img %{buildroot}%{_datadir}/waydroid-extra/images

%files
%dir %{_datadir}/waydroid-extra
%{_datadir}/waydroid-extra/images
%{_datadir}/waydroid-extra/images/%{type}.img

