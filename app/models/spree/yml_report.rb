module Spree
  class YmlReport < ApplicationRecord
    def self.send_report(name,text)
      self.create!(name: name, various_array: text)
    end
  end
end