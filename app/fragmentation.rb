class Fragmentation
  def self.generate
    puts '[Fragmentation] Generating fragmentation data'

    direct_dependencies = []

    Gemfiles.all.each do |appname, lockfile|
      lockfile.dependencies.map do |_, d|
        spec = lockfile.specs.find { |s| s.name == d.name }

        if spec.nil?
          puts "[x] Couldn't find spec for #{d.name} (#{appname})"
          next
        end

        direct_dependencies << Version.new(spec.name, spec.version, spec.to_s)
      end
    end

    output = []

    direct_dependencies.uniq(&:name).each do |gem|
      print '.'

      versions_of_gem_in_apps = direct_dependencies.select { |v| v.name == gem.name }
      next unless versions_of_gem_in_apps.size > 1

      versions = counts(versions_of_gem_in_apps.map(&:version).sort.map(&:to_s))
      children = versions.map do |v, count|
        { name: "#{gem.name} #{v}", size: count }
      end

      output << { name: gem.name, children: children }
    end

    File.write("source/fragmentation.json", JSON.pretty_generate(name: "versions", children: output))

    puts '√'
  end

  def self.get
    JSON.parse(File.read("source/fragmentation.json"))
  end
end
