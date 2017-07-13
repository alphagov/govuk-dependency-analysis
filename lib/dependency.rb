class Dependency
  attr_reader :name

  def initialize(data)
    @name = data["id"]
    @data = data
  end

  def depended_on
    @depended_on ||= @data["depended_on"].map { |gem| Application.find(gem) }
  end

  def depended_on_directly
    @depended_on_directly ||= @data["depended_on_directly"].map { |gem| Application.find(gem) }
  end

  def self.find(name)
    all.find { |gem| gem.name == name }
  end

  def self.all
    @@data ||= JSON.parse(File.read('public/matrix.json'))
    @@data['gems'].map { |gem_data| Dependency.new(gem_data) }
  end
end
