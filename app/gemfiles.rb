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

    applications = JSON.parse(HTTP.get('https://docs.publishing.service.gov.uk/apps.json'))
    applications.each do |application|
      puts application["app_name"]
      repo_name = application.dig('links', 'repo_url').split('/').last
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
