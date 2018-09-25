class Dependency
  attr_reader :name

  def initialize(data)
    @name = data["id"]
    @data = data
  end

  def depended_on
    @depended_on ||= @data["depended_on"].map { |app_name| Application.find(app_name) }.sort_by(&:name)
  end

  def apps_not_using_it
    @apps_not_using_it ||= Application.all.reject { |a| depended_on.map(&:name).include?(a.name) }
  end

  def einzelgem?
    depended_on.size == 1
  end

  def depended_on_directly
    @depended_on_directly ||= @data["depended_on_directly"].map { |gem| Application.find(gem) }.sort_by(&:name)
  end

  def depended_on_indirectly
    @depended_on_indirectly ||= (@data["depended_on"] - @data["depended_on_directly"]).map { |gem| Application.find(gem) }
  end

  def self.find(name)
    all.find { |gem| gem.name == name }
  end

  def self.all
    @@data ||= BaseData.get
    @@data['gems'].map { |gem_data| Dependency.new(gem_data) }
  end
end
