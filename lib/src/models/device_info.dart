/// Model representing device information
class DeviceInfo {
  /// Device name/model (e.g., "iPhone 13", "Pixel 6")
  final String? deviceName;

  /// Operating system name (e.g., "iOS", "Android")
  final String? deviceOS;

  /// Operating system version (e.g., "15.0", "12")
  final String? deviceOSVersion;

  /// Creates a new DeviceInfo instance
  const DeviceInfo({
    this.deviceName,
    this.deviceOS,
    this.deviceOSVersion,
  });

  /// Creates a DeviceInfo from a JSON map
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceName: json['deviceName'],
      deviceOS: json['deviceOS'],
      deviceOSVersion: json['deviceOSVersion'],
    );
  }

  /// Converts DeviceInfo to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'deviceOS': deviceOS,
      'deviceOSVersion': deviceOSVersion,
    };
  }

  @override
  String toString() {
    return 'DeviceInfo(deviceName: $deviceName, deviceOS: $deviceOS, deviceOSVersion: $deviceOSVersion)';
  }
}
