function FindProxyForURL(url, host) {
    var proxy = "PROXY proxy.staging.huatai.me:8123; DIRECT";

// If the hostname matches, send proxy.
    if (dnsDomainIs(host, "blocked.domain.com") ||
        shExpMatch(host, "(*.facebook.com|facebook.com)" ||
        shExpMatch(host, "(*.google.com|google.com)"))
    return proxy;

// If the requested website is hosted within the internal network, send direct.
    if (isPlainHostName(host) ||
        shExpMatch(host, "*.local") ||
        isInNet(dnsResolve(host), "10.0.0.0", "255.0.0.0") ||
        isInNet(dnsResolve(host), "172.16.0.0",  "255.240.0.0") ||
        isInNet(dnsResolve(host), "192.168.0.0",  "255.255.0.0") ||
        isInNet(dnsResolve(host), "127.0.0.0", "255.255.255.0"))
    return "DIRECT";

// DEFAULT RULE: direct
    return "DIRECT";
}
