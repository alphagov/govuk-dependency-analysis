class Gemfiles
  DIRECTORY = "cache/gemfiles"

  def self.all
    Dir.glob("#{DIRECTORY}/*").map do |filename|
      appname = filename.gsub("#{DIRECTORY}/", "")

      file = File.read(filename)
      lockfile = Bundler::LockfileParser.new(file)

      [appname, lockfile]
    end
  end

  def self.download
    begin
      sh "mkdir #{DIRECTORY}"
      sh "rm #{DIRECTORY}/*"
    rescue
    end

    applications = YAML.load(HTTP.get('https://raw.githubusercontent.com/alphagov/govuk-developer-docs/master/data/applications.yml'))
    repos = applications.each do |application|
      next if application["retired"]

      repo_name = application.fetch('github_repo_name')
      url = "https://raw.githubusercontent.com/alphagov/#{repo_name}/master/Gemfile.lock"
      response = HTTP.get(url)

      if response.code == 200
        print '.'
        File.write("#{DIRECTORY}/#{repo_name}", response)
      else
        puts "Skipping #{repo_name}"
      end
    end
  end
end
