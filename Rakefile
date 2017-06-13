require 'yaml'
require 'typhoeus'
require 'http'

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
