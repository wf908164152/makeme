#
#	RPM spec file for ${settings.title}
#
Summary: ${settings.title} -- A modern replacement for the autoconf and make tools
Name: ${settings.product}
Version: ${settings.version}
Release: ${settings.buildNumber}
License: Dual GPL/commercial
Group: Development/Other
URL: http://embedthis.com
Distribution: Embedthis
Vendor: Embedthis Software
BuildRoot: ${dir.rpm}/BUILDROOT/${settings.product}-${settings.version}-${settings.buildNumber}.${platform.mappedCpu}
AutoReqProv: no

%description
Bit is a replacement for the autoconf/make build tools. Bit is a single tool that configures, builds and generated native build projects for applications. It expresses build rules in the JavaScript language.

%prep

%build

%install
    mkdir -p ${dir.rpm}/BUILDROOT/${settings.product}-${settings.version}-${settings.buildNumber}.${platform.mappedCpu}
    cp -r ${dir.contents}/* ${dir.rpm}/BUILDROOT/${settings.product}-${settings.version}-${settings.buildNumber}.${platform.mappedCpu}

%clean

%files -f binFiles.txt

%post
if [ -x /usr/bin/chcon ] ; then 
	sestatus | grep enabled >/dev/null 2>&1
	if [ $? = 0 ] ; then
		for f in ${prefixes.vapp}/bin/*.so ; do
			chcon /usr/bin/chcon -t texrel_shlib_t $f
		done
	fi
fi
ldconfig -n ${prefixes.vapp}/bin

%preun
rm -f ${prefixes.app}/latest

%postun

