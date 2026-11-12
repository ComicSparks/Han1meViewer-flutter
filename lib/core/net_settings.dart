import '../src/rust/api/models.dart';

const hanimeHosts = ['hanime1.me', 'hanime1.com', 'hanimeone.me', 'javchu.com'];
const dohPresets = ['alidns', 'dnspod', 'cloudflare', 'custom'];
const proxyModes = ['system', 'none', 'http', 'socks5'];

extension NetSettingsCopy on NetSettings {
  NetSettings copyWith({
    String? domain,
    bool? useCustomMirror,
    String? customMirror,
    String? videoLanguage,
    bool? useBuiltInHosts,
    String? customHosts,
    bool? useDoh,
    String? dohPreset,
    String? dohCustomUrl,
    String? dohBootstrapIps,
    int? dohTimeoutSecs,
    String? proxyMode,
    String? proxyHost,
    int? proxyPort,
    int? imageCacheLimitMb,
    int? downloadConcurrency,
    int? downloadSpeedLimitKb,
  }) =>
      NetSettings(
        domain: domain ?? this.domain,
        useCustomMirror: useCustomMirror ?? this.useCustomMirror,
        customMirror: customMirror ?? this.customMirror,
        videoLanguage: videoLanguage ?? this.videoLanguage,
        useBuiltInHosts: useBuiltInHosts ?? this.useBuiltInHosts,
        customHosts: customHosts ?? this.customHosts,
        useDoh: useDoh ?? this.useDoh,
        dohPreset: dohPreset ?? this.dohPreset,
        dohCustomUrl: dohCustomUrl ?? this.dohCustomUrl,
        dohBootstrapIps: dohBootstrapIps ?? this.dohBootstrapIps,
        dohTimeoutSecs: dohTimeoutSecs ?? this.dohTimeoutSecs,
        proxyMode: proxyMode ?? this.proxyMode,
        proxyHost: proxyHost ?? this.proxyHost,
        proxyPort: proxyPort ?? this.proxyPort,
        imageCacheLimitMb: imageCacheLimitMb ?? this.imageCacheLimitMb,
        downloadConcurrency: downloadConcurrency ?? this.downloadConcurrency,
        downloadSpeedLimitKb: downloadSpeedLimitKb ?? this.downloadSpeedLimitKb,
      );
}
