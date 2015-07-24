require 'formula'

class Tokumx < Formula
  homepage 'http://www.tokutek.com/products/tokumx-for-mongodb/'
  version '1.4.2'

  raise FormulaSpecificationError, 'Formula requires Mavericks or Yosemite (OSX 10.9 or 10.10)' unless MacOS.version >= :mavericks

  url 'https://github.com/igagnidz/tokumx-osx-build/raw/master/tokumx-1.4.2-osx-x86_64-mavericks%2B256MBscanandorder.tar.gz'
  sha256 'a6a9b2c1d554cb8cddd5b85b3d9494b78021111e96f25c0dda37ccdf1eccd612'

  conflicts_with 'mongodb'

  def install
    bin.install Dir['bin/*']
    prefix.install Dir['lib64']
    prefix.install Dir['GNU-AGPL-3.0']
    prefix.install Dir['THIRD-PARTY-NOTICES']
    prefix.install Dir['NEWS']
    prefix.install Dir['README']
    prefix.install Dir['README-TOKUKV']

    (buildpath+"tokumx.conf").write tokumx_conf
    etc.install "tokumx.conf"

    (var+'tokumx').mkpath
    (var+'log/tokumx').mkpath
  end

  def tokumx_conf; <<-EOS.undent
    # Store data in #{var}/tokumx instead of the default /data/db
    dbpath = #{var}/tokumx

    # Append logs to #{var}/log/tokumx/tokumx.log
    logpath = #{var}/log/tokumx/tokumx.log
    logappend = false

    # Only accept local connections
    bind_ip = 127.0.0.1

    # Only use ~2GB of ram for cache
    cacheSize = 2G

    # Read page size to use when creating new collections
    #defaultReadPageSize = 256K
  EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/tokumx.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/tokumx.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/tokumx/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/tokumx/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>4096</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>20000</integer>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/mongod", '--sysinfo'
  end
end
