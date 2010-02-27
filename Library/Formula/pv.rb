require 'formula'

class Pv <Formula
  url 'http://pipeviewer.googlecode.com/files/pv-1.1.4.tar.bz2'
  homepage 'http://www.ivarch.com/programs/pv.shtml'
  md5 '63033e090d61a040407bfd043aeb6d27'

  def install
    ENV.gcc_4_2

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-nls"
    system "make install"
  end
end
