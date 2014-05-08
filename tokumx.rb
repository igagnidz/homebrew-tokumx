require 'formula'

class Tokumx < Formula
  homepage 'http://www.tokutek.com/products/tokumx-for-mongodb/'
  version '1.4.1'

  url 'https://github.com/igagnidz/tokumx-osx-build/raw/master/tokumx-1.4.1-osx-x86_64-mavericks%2B256MBscanandorder.tar.gz'
  sha256 '61fcffbd2afd1147bf51e2467527b32a1f9d976a1ff7a6773cadcfd57083d208'

  def install
    prefix.install Dir['*']

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
        <integer>102400</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>102400</integer>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/mongod", '--sysinfo'
  end
end
