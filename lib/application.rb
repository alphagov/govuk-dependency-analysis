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

  def direct_dependency_count
    @data["direct_dependencies"].size
  end

  def dependency_count
    @data["dependencies"].size
  end

  def dependencies
    @data["dependencies"].map { |dependency_name| Dependency.find(dependency_name) }
  end

  def transitive_dependency_count
    dependency_count - direct_dependency_count
  end
end
