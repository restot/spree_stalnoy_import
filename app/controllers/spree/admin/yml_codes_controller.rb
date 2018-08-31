module Spree
  module Admin
    class YmlCodesController < ResourceController


      def index
        @ymls = Spree::YmlCode.order('id ASC')
      end

      def start
        code = Spree::YmlCode.find(params[:id])

        Delayed::Job.enqueue YmlProcessorJob.new(code.name,code.link,code.update_available,code.update_price), :queue => 'yml', :cron => code.cron

      end


    end
  end
end


