class Gemfiles
  def self.all
    Dir.glob("../cache/gemfiles/*").map do |filename|
      appname = filename.gsub("../cache/gemfiles/", "")

      file = File.read(filename)
      lockfile = Bundler::LockfileParser.new(file)

      [appname, lockfile]
    end
  end
end
