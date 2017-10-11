require 'yaml'
require 'json'
require 'http'
require 'grit'

Version = Struct.new(:name, :version, :name_and_version)

def counts(array)
  array.each_with_object(Hash.new(0)) { |el, counts| counts[el] += 1 }
end

require_relative 'app/gemfiles'
require_relative 'app/dependency'
require_relative 'app/application'
require_relative 'app/base_data'
require_relative 'app/jaccard_matrix'
require_relative 'app/fragmentation'
require_relative 'app/network'

desc "Download & rebuild everything"
task rebuild: %i[download_gemfiles precalculate_data]

desc "Download the Gemfiles for the applications"
task :download_gemfiles do
  Gemfiles.download
end

desc "Outputs all the applictions and gems they depend on, gems and apps they depend on"
task :precalculate_data do
  BaseData.generate
  Network.generate
  Fragmentation.generate
  JaccardMatrix.generate
end

desc "Fetch all gemfile.lock's"
task :fetch_history do
  repo = Grit::Repo.new("../whitehall")

  `mkdir -p cache/gem-histories/whitehall`

  repo.log('master', 'Gemfile.lock').reverse.each_with_index do |line, i|
    puts `cd ../whitehall && git checkout #{line.sha} -- Gemfile.lock && cp Gemfile.lock ../diversion/cache/gem-histories/whitehall/gemfile-#{line.committed_date.to_i}`
  end
end

task :export_versions do
  direct_dependencies = []

  Gemfiles.all.each do |appname, lockfile|
    lockfile.dependencies.map do |_, d|
      spec = lockfile.specs.find { |s| s.name == d.name }
      direct_dependencies << Version.new(spec.name, spec.version, spec.to_s)
    end
  end

  output = []

  direct_dependencies.uniq(&:name).sort_by(&:name).each do |app|
    versions = counts(direct_dependencies.select { |v| v.name == app.name }.map(&:version).sort.map(&:to_s))
    output << { gem_name: app.name, versions: versions}
  end

  File.write("public/versions.json", JSON.pretty_generate(output))
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

task :rubygems_version_info do
  begin
    sh "mkdir cache/gem-versions"
    sh "rm cache/gem-versions/*"
  rescue
  end

  gems = JSON.parse(File.read("public/versions.json"))
  gems.each do |gem|
    gem_name = gem["gem_name"]
    url = "https://rubygems.org/api/v1/versions/#{gem_name}.json"
    response = HTTP.get(url)
    File.write("cache/gem-versions/#{gem_name}", response)
  end
end

task :output_age_of_lagging_dependencies do
  statuses = JSON.parse(File.read("public/versions.json"))

  Dir.glob('cache/gem-versions/*').each do |filename|
    app_name = filename.gsub('cache/gem-versions/', '')

    versions = JSON.parse(File.read("cache/gem-versions/#{app_name}"))
    latest_version = versions.first
    latest_release_date = Date.parse(latest_version["built_at"])

    status = statuses.find { |s| s["gem_name"] == app_name }

    cumul = status["versions"].flat_map do |version_number, version_count|
      this_version = versions.find { |v| v["number"] == version_number }
      next unless this_version
      this_release_date = Date.parse(this_version["built_at"])
      days_behind = (latest_release_date - this_release_date).to_i
      # puts "#{version_number} is #{days_behind} days behind #{latest_version["number"]}"
      # puts version_count
      [days_behind] * version_count.to_i
    end.compact

    next if cumul.size < 2

    average_age = cumul.reduce(&:+) / cumul.size.to_f

    puts "#{app_name} (#{cumul.size}) avg: #{average_age.to_i}, max: #{cumul.max}, min: #{cumul.min}"
  end
end

task :competitors do
  YAML.load_file("groups.yml").each do |group, gems|
    puts "\n\n# #{group}"
    d = []
    gems.each do |gem|
      deps = Dependency.find(gem)
      puts "#{gem}: #{deps.depended_on_directly}"
      d << deps.depended_on_directly
    end

    d.flatten!

    # puts "others: #{Application.all.map(&:name) - d}"
  end
end
