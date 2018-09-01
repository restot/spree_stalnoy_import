YmlProcessorJob = Struct.new(:name,:url,:update_available,:update_price) do

  def perform

    IO.copy_stream(open(url,
                        'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.183 Safari/537.36 Vivaldi/1.96.1147.36',
                        'Accept' => 'text/html',
                        'Accept-Encoding'=> 'gzip'), Rails.root.join('yml', name.to_s ))

    xml = Zlib::GzipReader.open(Rails.root.join('yml',name.to_s)) {|gz| gz.read}
    json = Hash.from_xml(xml).to_json
    File.open(Rails.root.join('yml', name.to_s + '.json'), 'w+').write json


    json = JSON.parse(File.open(Rails.root.join('yml', name.to_s + '.json')).read)

    json['yml_catalog']['shop']['offers']['offer'].each_with_index do |offer, index|
      variant = Spree::Variant.find_by(sku: offer['vendorCode'])
      unless variant.nil?

        if update_available === true
          variant.stock_items.update(backorderable: (offer['available'].to_s === "true" )? true : false)
        end

        if update_price === true
          variant.update(price: offer['price'].to_d)
        end


        Spree::Product.find_by(id: variant.product_id).update(discontinue_on: Time.now + 14.day)

      end
    end
  end



end