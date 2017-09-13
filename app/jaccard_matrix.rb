class JaccardMatrix
  def self.generate
    puts '[Jaccard] Generating Jaccard similarity matrix'

    links = Application.all.flat_map do |app|
      Application.all.flat_map do |other|
        print '.'
        similarity = jaccard(app.dependencies.map(&:name), other.dependencies.map(&:name))
        { source: app.name, target: other.name, value: (similarity * 100).to_i }
      end
    end

    out = {
      nodes: Application.all.map { |app| { id: app.name } },
      links: links,
    }

    File.write('source/similarity.json', JSON.pretty_generate(out))

    puts "√"
  end

  # https://en.wikipedia.org/wiki/Jaccard_index
  def self.jaccard(a,b)
    intersection = a & b
    union = (a + b).uniq
    intersection.size.to_f / union.size.to_f
  end
end
