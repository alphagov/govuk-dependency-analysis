class Application
  attr_reader :name

  def initialize(data)
    @name = data["id"]
  end

  def self.all
    data = JSON.parse(File.read('../public/matrix.json'))
    data['applications'].map { |app_data| Application.new(app_data) }
  end
end
