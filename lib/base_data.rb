class BaseData
  def self.generate
    gems = {}
    applications = []

    Gemfiles.all.each do |app_name, lockfile|
      applications << {
        id: app_name,
        direct_dependencies: lockfile.dependencies.map { |_, d| d.name },
        dependencies: lockfile.specs.map(&:name),
      }

      lockfile.dependencies.map do |_, d|
        gems[d.name] ||= { depended_on: [], depended_on_directly: []}
        gems[d.name][:depended_on_directly] << app_name
      end

      lockfile.specs.map do |d|
        gems[d.name] ||= { depended_on: [], depended_on_directly: []}
        gems[d.name][:depended_on] << app_name
      end
    end

    gems_output = gems.map do |name, data|
      data[:id] = name
      data
    end

    output = {
      applications: applications,
      gems: gems_output,
    }

    File.write("public/matrix.json", JSON.pretty_generate(output))
  end
end
