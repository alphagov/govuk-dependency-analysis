class Stats
  def self.get
    data = BaseData.get

    output = {
      application_count: Application.all.count,
      dependency_count: Dependency.all.count,
      direct_dependency_count: Dependency.all.select { |d| d.depended_on_directly.size > 0 }.count,
      transitive_dependency_count: Dependency.all.select { |d| d.depended_on_directly.size == 0 }.count,
      einzelgems: Dependency.all.select(&:einzelgem?).count,
    }

    output
  end
end
