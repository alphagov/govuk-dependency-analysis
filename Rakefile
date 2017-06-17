require 'yaml'
require 'json'
require 'http'

Version = Struct.new(:name, :version, :name_and_version)

def counts(array)
  array.each_with_object(Hash.new(0)) { |el, counts| counts[el] += 1 }
end

task :apps_and_gems do
  output = { nodes: [], links: [] }
  Dir.glob("cache/*").each do |filename|
    file = File.read(filename)
    lockfile = Bundler::LockfileParser.new(file)
    appname = filename.gsub('cache/', '')

    output[:nodes] << {
      id: appname,
      group: 'applications',
      dependency_count: lockfile.dependencies.size,
    }

    lockfile.dependencies.map do |d|

      existing_node = output[:nodes].find { |n| n[:id] == d.name }
      if existing_node
        existing_node[:usage_count] = existing_node[:usage_count] + 1
        output[:nodes] << existing_node
      else
        output[:nodes] << { id: d.name, group: 'gems', usage_count: 1 }
      end

      output[:links] << { source: appname, target: d.name }
    end
  end

  output[:nodes].uniq!
  output[:links].uniq!

  File.write("public/network.json", JSON.pretty_generate(output))
end

task :analyse do
  direct_dependencies = []
  Dir.glob("cache/*").each do |filename|
    file = File.read(filename)
    lockfile = Bundler::LockfileParser.new(file)

    lockfile.dependencies.map do |_, d|
      spec = lockfile.specs.find { |s| s.name == d.name }
      direct_dependencies << Version.new(spec.name, spec.version, spec.to_s)
    end
  end

  output = []

  direct_dependencies.uniq(&:name).sort_by(&:name).each do |app|
    versions = counts(direct_dependencies.select { |v| v.name == app.name }.map(&:version).sort.map(&:to_s))
    output << { app_name: app.name, versions: versions}
  end

  File.write("public/versions.json", JSON.pretty_generate(output))
end

task :fragmentation do
  direct_dependencies = []
  Dir.glob("cache/*").each do |filename|
    file = File.read(filename)
    lockfile = Bundler::LockfileParser.new(file)

    lockfile.dependencies.map do |d|
      spec = lockfile.specs.find { |s| s.name == d.name }
      direct_dependencies << Version.new(spec.name, spec.version, spec.to_s)
    end
  end

  output = []

  direct_dependencies.uniq(&:name).sort_by(&:name).each do |gem|
    versions = counts(direct_dependencies.select { |v| v.name == gem.name }.map(&:version).sort.map(&:to_s))
    children = versions.map do |v, count|
      { name: "#{gem.name} #{v}", size: count }
    end

    output << { name: gem.name, children: children }
  end

  File.write("public/fragmentation.json", JSON.pretty_generate(name: "versions", children: output))
end

task :download do
  sh "rm cache/*"
  applications = YAML.load(HTTP.get('https://raw.githubusercontent.com/alphagov/govuk-developer-docs/master/data/applications.yml'))
  repos = applications.each do |application|
    next if application["retired"]

    repo_name = application.fetch('github_repo_name')
    url = "https://raw.githubusercontent.com/alphagov/#{repo_name}/master/Gemfile.lock"
    response = HTTP.get(url)

    if response.code == 200
      File.write("cache/#{repo_name}", response)
    else
      puts "Skipping #{repo_name}"
    end
  end
end

task :download_versions do
  begin
    sh "mkdir cache/ruby-versions"
    sh "rm cache/ruby-versions/*"
  rescue
  end

  applications = YAML.load(HTTP.get('https://raw.githubusercontent.com/alphagov/govuk-developer-docs/master/data/applications.yml'))
  repos = applications.each do |application|
    next if application["retired"]

    repo_name = application.fetch('github_repo_name')
    url = "https://raw.githubusercontent.com/alphagov/#{repo_name}/master/.ruby-version"
    response = HTTP.get(url)

    if response.code == 200
      File.write("cache/ruby-versions/#{repo_name}", response)
    else
      puts "Skipping #{repo_name}"
    end
  end
end
