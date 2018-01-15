require "govuk_security_audit/scanner"

class Vulnerabilities
  FILENAME = "source/vulnerabilities.json".freeze

  def self.generate
    puts '[Vulnerabilities] Updating advisory db'
    Bundler::Audit::Database.update!
    puts "ruby-advisory-db: #{Bundler::Audit::Database.new.size} advisories"

    puts '[Vulnerabilities] Generating list of gem vulnerabilities'

    vulnerabilities = {}
    Dir['cache/gemfiles/*'].each do |gemfile|
      print '.'
      scanner = GovukSecurityAudit::Scanner.new(gemfile)
      scanner.scan do |result|
        if result.is_a? GovukSecurityAudit::Scanner::UnpatchedGem
          vuln = {
            name: result.gem.name,
            version: result.gem.version.to_s,
            advisory: result.advisory.to_s,
            criticality: result.advisory.criticality,
            url: result.advisory.url,
            title: result.advisory.title,
            description: result.advisory.description,
            patched_versions: result.advisory.patched_versions.map(&:to_s)
          }

          vulnerabilities[File.basename(gemfile)] ||= []
          vulnerabilities[File.basename(gemfile)] << vuln
        end
      end
    end

    File.write(FILENAME, JSON.pretty_generate(vulnerabilities))

    puts "√"
  end

  def self.find(app)
    get[app] || []
  end

  def self.get
    @@data ||= JSON.parse(File.read(FILENAME))
  end
end
