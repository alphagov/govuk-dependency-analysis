class Application
  attr_reader :name

  def initialize(data)
    @name = data["id"]
    @data = data
  end

  def self.all
    @@data ||= BaseData.get
    @@data['applications'].map { |app_data| Application.new(app_data) }
  end

  def self.find(name)
    all.find { |app| app.name == name }
  end

  def api_data
    JSON.parse(HTTP.get("https://docs.publishing.service.gov.uk/apps/#{name}.json").body)
  end

  def einzelgem_count
    einzelgems.size
  end

  def einzelgems
    dependencies.select(&:einzelgem?)
  end

  def dependencies
    @data["dependencies"].map { |dependency_name| Dependency.find(dependency_name) }
  end

  def dependency_count
    dependencies.size
  end

  def direct_dependencies
    @data["direct_dependencies"].map { |dependency_name| Dependency.find(dependency_name) }
  end

  def direct_dependency_count
    direct_dependencies.size
  end

  def transitive_dependency_count
    dependency_count - direct_dependency_count
  end

  def vulnerabilities
    Vulnerabilities.find(name)
  end

  def vulnerability_count
    vulnerabilities.size
  end
end
