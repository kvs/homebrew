class MidnightCommander < Formula
  desc "Terminal-based visual file manager"
  homepage "https://www.midnight-commander.org/"
  url "http://ftp.midnight-commander.org/mc-4.8.15.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mc/mc_4.8.15.orig.tar.xz"
  sha256 "cf4e8f5dfe419830d56ca7e5f2495898e37ebcd05da1e47ff7041446c87fba16"

  head "https://github.com/MidnightCommander/mc.git"

  bottle do
    sha256 "614744903b7ea7d59b79ab8722b83d4537bf04a6b14c534c9e8135ab25206798" => :el_capitan
    sha256 "f15a295f0a18df0302fc79e2ce81e5d7950985d4160b3eeff7558e72ca810427" => :yosemite
    sha256 "e001897e0301e20f5d04dfc6ec728fb47ebb708ca3cae59a0cfa666771794d90" => :mavericks
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
 
