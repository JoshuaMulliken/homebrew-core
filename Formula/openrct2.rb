class Openrct2 < Formula
  desc "Open source re-implementation of RollerCoaster Tycoon 2"
  homepage "https://openrct2.io/"
  url "https://github.com/OpenRCT2/OpenRCT2.git",
      tag:      "v0.3.0",
      revision: "135cc10b4766085ce35097b5830f612e36b47ba0"
  license "GPL-3.0"
  head "https://github.com/OpenRCT2/OpenRCT2.git", branch: "develop"

  bottle do
    cellar :any
    sha256 "b77f8f232b8af2d615734f94c43b60bebc656c3dacdd1ad50a3b31b7f3e945e0" => :catalina
    sha256 "2f9f44ee3c1f9b60b32a60cb40b8a1eabbcddad89d8a3c6c37a04fa41c799493" => :mojave
    sha256 "50f6ea68a2265b15ee444ffe1ed624d3ff3cfee98fc914cac148d42b6232d920" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "duktape"
  depends_on "freetype" # for sdl2_ttf
  depends_on "icu4c"
  depends_on "jansson"
  depends_on "libpng"
  depends_on "libzip"
  depends_on macos: :mojave # `error: call to unavailable member function 'value': introduced in macOS 10.14`
  depends_on "openssl@1.1"
  depends_on "sdl2"
  depends_on "sdl2_ttf"
  depends_on "speexdsp"

  resource "title-sequences" do
    url "https://github.com/OpenRCT2/title-sequences/releases/download/v0.1.2c/title-sequences.zip"
    sha256 "5284333fa501270835b5f0cf420cb52155742335f5658d7889ea35d136b52517"
  end

  resource "objects" do
    url "https://github.com/OpenRCT2/objects/releases/download/v1.0.16/objects.zip"
    sha256 "ac9e5b605c6ec874bbc7e01c81ac31e715598f7031b0c54ec484fbcea669768a"
  end

  def install
    # Avoid letting CMake download things during the build process.
    (buildpath/"data/title").install resource("title-sequences")
    (buildpath/"data/object").install resource("objects")

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    # By default macOS build only looks up data in app bundle Resources
    libexec.install bin/"openrct2"
    (bin/"openrct2").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/openrct2" "$@" "--openrct2-data-path=#{pkgshare}"
    EOS
  end

  test do
    assert_match "OpenRCT2, v#{version}", shell_output("#{bin}/openrct2 -v")
  end
end
