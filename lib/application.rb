class Application
  attr_reader :name

  def initialize(data)
    @name = data["id"]
    @data = data
  end

  def self.all
    @@data ||= JSON.parse(File.read('public/matrix.json'))
    @@data['applications'].map { |app_data| Application.new(app_data) }
  end

  def self.find(name)
    all.find { |app| app.name == name }
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
end
