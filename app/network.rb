class Network
  def self.generate
    puts '[Network] Generating network'

    output = { nodes: [], links: [] }

    matrix = BaseData.get

    matrix["applications"].each do |application|
      output[:nodes] << {
        id: application.fetch("id"),
        group: 'applications',
        dependency_count: application["dependencies"].size,
      }

      application["direct_dependencies"].each do |gem_name, attrs|
        output[:links] << { source: application["id"], target: gem_name }
      end

      print '.'
    end

    matrix["gems"].each do |attrs|
      next unless attrs["depended_on_directly"].size > 0
      output[:nodes] << { id: attrs["id"], group: 'gems', usage_count: attrs["depended_on_directly"].size }
    end

    File.write("source/network.json", JSON.pretty_generate(output))

    puts '√'
  end
end
