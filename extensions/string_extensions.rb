
# Extensions for String to make life easier
class String

  def inflate
    zstream = Zlib::GzipReader.new(StringIO.new(self))
    buf = zstream.read
    zstream.finish
    buf
  end

  def pop
    last = self[-1,1]
    self.chop!
    last
  end
end