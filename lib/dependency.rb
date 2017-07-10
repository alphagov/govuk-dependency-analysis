class Dependency
  attr_reader :name, :depended_on, :depended_on_directly

  def initialize(data)
    @name = data["id"]
    @depended_on = data["depended_on"]
    @depended_on_directly = data["depended_on_directly"]
  end

  def self.find(name)
    all.find { |gem| gem.name == name }
  end

  def self.all
    data = JSON.parse(File.read('public/matrix.json'))
    data['gems'].map { |gem_data| Dependency.new(gem_data) }
  end
end
