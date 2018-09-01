ConvertXmlToJsonJob = Struct.new(:input,:out) do

  def perform
    xml = Zlib::GzipReader.open(Rails.root.join('yml',input.to_s)) {|gz| gz.read}
    json = Hash.from_xml(xml).to_json
    File.open(Rails.root.join('yml', out.to_s), 'w+').write json
  end

end