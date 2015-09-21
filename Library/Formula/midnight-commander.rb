class MidnightCommander < Formula
  desc "Terminal-based visual file manager"
  homepage "https://www.midnight-commander.org/"
  url "http://ftp.midnight-commander.org/mc-4.8.14.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mc/mc_4.8.14.orig.tar.xz"
  sha256 "6b1f74efbdf394bfab084f4d2ea2e72173de5f12cd42be2533ca2c3b72edb8e6"

  head "https://github.com/MidnightCommander/mc.git"

  bottle do
    revision 1
    sha256 "e9f5109f2fd2927096b9b6cab05c5509695b313b072126c6f352d7ba3891f748" => :el_capitan
    sha256 "9e25d3d107929070400bcf8f928e5adc3f77c6f4942544cbf7b26822ecc425d6" => :yosemite
    sha256 "faa3115190a66947d3141619d285c55fac451cd154be9a6ea053b37239ecd085" => :mavericks
    sha256 "e75f3aed5a28a381a1bce9461108d21e76abb094d98ad8cfe580720ad390d7e8" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl"
  depends_on "s-lang"
  depends_on "libssh2"

  def patches
    DATA
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--without-x",
                          "--with-screen=slang",
                          "--enable-vfs-sftp"
    system "make", "install"

    # https://www.midnight-commander.org/ticket/3509
    inreplace libexec/"mc/ext.d/text.sh", "man -P cat -l ", "man -P cat "
  end

  test do
    assert_match "GNU Midnight Commander", shell_output("#{bin}/mc --version")
  end
end

__END__
diff --git a/src/subshell.c b/src/subshell.c
index 70378b2..74daba0 100644
--- a/src/subshell.c
+++ b/src/subshell.c
@@ -770,7 +770,7 @@ init_subshell (void)
 {
     /* This must be remembered across calls to init_subshell() */
     static char pty_name[BUF_SMALL];
-    char precmd[BUF_SMALL];
+    char precmd[BUF_SMALL*4];
 
     switch (check_sid ())
     {
@@ -900,10 +900,9 @@ init_subshell (void)
         break;
     case FISH:
         g_snprintf (precmd, sizeof (precmd),
-                    "function fish_prompt ; pwd>&%d;kill -STOP %%self; end\n",
+                    " functions -c fish_prompt __mc_saved_fish_prompt; function fish_prompt; while test -z (pwd); cd ..; end; __mc_saved_fish_prompt; pwd>&%d; kill -STOP %%self; end\n",
                     subshell_pipe[WRITE]);
         break;
-
     }
     write_all (mc_global.tty.subshell_pty, precmd, strlen (precmd));
 
