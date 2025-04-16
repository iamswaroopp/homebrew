class Libxmlsec1AT12 < Formula
  desc "XML security library"
  homepage "https://www.aleksey.com/xmlsec/"
  url "https://www.aleksey.com/xmlsec/download/xmlsec1-1.2.41.tar.gz"
  sha256 "a0aecfdf1f190c6b866a278e42746b6582729a493f6ac6a1556a4663ff3ce625"
  license "MIT"

  livecheck do
    url "https://www.aleksey.com/xmlsec/download/"
    regex(/href=.*?xmlsec1[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end



  depends_on "pkgconf" => :build
  depends_on "gnutls" # Yes, it wants both ssl/tls variations
  depends_on "libgcrypt"
  depends_on "libxml2"
  depends_on "openssl@3"
  uses_from_macos "libxslt"
  conflicts_with "libxmlsec1", because: "libxmlsec1 will provide 1.3 version"


  # Add HOMEBREW_PREFIX/lib to dl load path
  patch :DATA

  def install
    args = [
      "--disable-crypto-dl",
      "--disable-apps-crypto-dl",
      "--with-nss=no",
      "--with-nspr=no",
      "--enable-mscrypto=no",
      "--enable-mscng=no",
      "--with-openssl=#{Formula["openssl@3"].opt_prefix}",
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"xmlsec1", "--version"
    system bin/"xmlsec1-config", "--version"
  end
end

__END__
diff --git a/src/dl.c b/src/dl.c
index 6e8a56a..0e7f06b 100644
--- a/src/dl.c
+++ b/src/dl.c
@@ -141,6 +141,7 @@ xmlSecCryptoDLLibraryCreate(const xmlChar* name) {
     }

 #ifdef XMLSEC_DL_LIBLTDL
+    lt_dlsetsearchpath("HOMEBREW_PREFIX/lib");
     lib->handle = lt_dlopenext((char*)lib->filename);
     if(lib->handle == NULL) {
         xmlSecError(XMLSEC_ERRORS_HERE,
