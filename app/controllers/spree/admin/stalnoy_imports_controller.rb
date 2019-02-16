module Spree
  module Admin
    class StalnoyImportsController < ResourceController

      include ActionController::Live

      def edit
        Spree::StalnoyImport.find(params[:id]).update(last_row: nil, data_prepared: nil)
      end

      def test_stream
        response.headers['Content-Type'] = 'text/event-stream'
        10.times {|n|
          response.stream.write "data: #{n}...\n\n"
          sleep 1
        }

      rescue IOError, ActionController::Live::ClientDisconnected
        logger.info "Stream closed"
      ensure
        response.stream.close
      end

      def stream
        response.headers['Content-Type'] = 'text/event-stream'
        @vendor = Spree::StalnoyImport.find(params[:id])

        if @vendor.data_prepared.nil?
          StalnoyImport.uncached do
            response.stream.write "data: #{Hash['status' => 'preparing'].to_json}\n\n"
            @rules = JSON.parse @vendor.rows
            @ruls_item_code = StalnoyRules.rules_parse(@vendor.rows, "item_code")
            @ruls_price = StalnoyRules.rules_parse(@vendor.rows, "price")
            @ruls_available = StalnoyRules.rules_parse(@vendor.rows, "available")
            @ruls_unavailable = StalnoyRules.rules_parse(@vendor.rows, "unavailable")
            @ruls_on_order = StalnoyRules.rules_parse(@vendor.rows, "on_order")
            @data = ActiveSupport::JSON.decode(@vendor.data).to_a[0][1] if Spree::StalnoyImport.exists?(params[:id])
            @preset = []
            @template = ActiveSupport::JSON.decode(@vendor.cols)
            @data.count.times do |i|
              item_code_current_value = @data[i][@template["item_code"].to_i]
              price_current_value = (@rules["white_space"] == 'true') ? @data[i][@template["price"].to_i].to_s.sub(',', '').to_f : (@rules["white_space"] == 'false') ? @data[i][@template["price"].to_i].to_s.sub(',', '.').to_f : @data[i][@template["price"].to_i].to_f
              available_current_value = @data[i][@template["available"].to_i]

              if StalnoyRules.bool_and(@ruls_item_code, item_code_current_value) and StalnoyRules.bool_and(@ruls_price, price_current_value) and (StalnoyRules.bool_or(@ruls_available, available_current_value) or StalnoyRules.bool_or(@ruls_on_order, available_current_value) or StalnoyRules.bool_or(@ruls_unavailable, available_current_value))
                @preset << [
                    item_code_current_value,
                    price_current_value,
                    available_current_value
                ]
                response.stream.write "data: #{Hash['status' => 'preparing',
                                                    'total' => @data.count,
                                                    'last_row' => i + 1,
                                                    'item_code' => item_code_current_value,
                                                    'price' => price_current_value,
                                                    'id' => params[:id]].to_json}\n\n"
              else
                response.stream.write "data: #{Hash['status' => 'preparing',
                                                    'total' => @data.count,
                                                    'last_row' => i + 1,
                                                    'item_code' => item_code_current_value,
                                                    'state' => 'error',
                                                    'id' => params[:id]].to_json}\n\n"
              end

            end
            @vendor.update(data_prepared: @preset.to_json)
          end
          @vendor = Spree::StalnoyImport.find(params[:id])
        end


        # if @vendor.last_row.nil?
        #   @count = ActiveSupport::JSON.decode(@vendor.data_prepared).count
        #   @count += 1;
        #   response.stream.write "data: #{Hash['status'=> 'nil_last_row','count' => @count].to_json}\n\n"
        # end

        unless params[:id].nil?
          @count = ActiveSupport::JSON.decode(@vendor.data_prepared).length
          # @count += 1;
          last_row = (@vendor.last_row.nil?) ? 0 : @vendor.last_row
          if @count > last_row
            i = 0;
            data = ActiveSupport::JSON.decode(@vendor.data_prepared).to_a
            data.each_with_index do |row, index|
              if @vendor.last_row.to_i > index
                next
              end

              variant = Spree::Variant.find_by(sku: row[0])
              if !variant.nil?
                currency = JSON.parse(@vendor.cols)["currency"]

                if (currency == '$SOURCE' or currency == nil or currency == '')
                  variant.update(cost_price: row[1].to_s.to_f)

                  Spree::Product.find_by(id: variant.product_id).update(discontinue_on: Time.now + 14.day)
                else
                  variant.update(cost_price: row[1].to_s.to_f, cost_currency: currency)
                  Spree::Product.find_by(id: variant.product_id).update(discontinue_on: Time.now + 14.day)
                end
                response.stream.write "data: #{Hash['status' => 'work',
                                                    'total' => @count,
                                                    'last_row' => index + 1,
                                                    'id' => params[:id],
                                                    'vendor' => @vendor.name,
                                                    'currency' => currency,
                                                    'item_code' => row[0],
                                                    'price' => row[1]
                ].to_json}\n\n"
                else
                response.stream.write "data: #{Hash['status' => 'work',
                                                    'total' => @count,
                                                    'last_row' => index + 1,
                                                    'id' => params[:id],
                                                    'vendor' => @vendor.name
                ].to_json}\n\n"
              end

              if i >= 10
                @vendor.update(last_row: index)
                i = 0
              end


              i += 1
            end
            @vendor.update(last_row: @count)
            response.stream.write "data: #{Hash['status' => 'done',
                                                'total' => @count,
                                                'last_row' => @vendor.last_row,
                                                'id' => params[:id],
                                                'vendor' => @vendor.name
            ].to_json}\n\n"
          else
            response.stream.write "data: #{Hash['status' => 'done',
                                                'total' => @count,
                                                'last_row' => @vendor.last_row,
                                                'id' => params[:id],
                                                'vendor' => @vendor.name
            ].to_json}\n\n"
          end


        end


      rescue IOError, ActionController::Live::ClientDisconnected
        logger.info "Stream closed"
      ensure
        response.stream.close
      end


      def upload
        @stalnoy_imports = Spree::StalnoyImport.order('id ASC')

      end


      def index
        @stalnoy_imports = Spree::StalnoyImport.order('id ASC')
      end


      def rules
        @test = "hello"
        @stalnoy_imports = Spree::StalnoyImport.all

      end

      def rows
        @vendor = Spree::StalnoyImport.find(params[:id])
        @data = ActiveSupport::JSON.decode(@vendor.data).to_a[0][1] if Spree::StalnoyImport.exists?(params[:id])
        @preset = []
        @template = ActiveSupport::JSON.decode(@vendor.cols)
        if params[:size] == 'all'
          @data.each_with_index do |val, i|
            @preset << [
                @data[i][@template["item_code"].to_i],
                (@data[i][@template["price"].to_i].nil?) ? '' : @data[i][@template["price"].to_i].delete(',').to_f,
                @data[i][@template["available"].to_i]
            ]
          end
        else
          ((params[:size] != nil) ? params[:size].to_i : 50).times do |i|

            @preset << [
                @data[i][@template["item_code"].to_i],
                (@data[i][@template["price"].to_i].nil?) ? '' : @data[i][@template["price"].to_i].delete(',').to_f,
                @data[i][@template["available"].to_i]
            ]
          end
        end


        if @vendor.rows != nil


          @ruls_item_code = StalnoyRules.rules_parse(@vendor.rows, "item_code")
          @ruls_price = StalnoyRules.rules_parse(@vendor.rows, "price")
          @ruls_available = StalnoyRules.rules_parse(@vendor.rows, "available")
          @ruls_unavailable = StalnoyRules.rules_parse(@vendor.rows, "unavailable")
          @ruls_on_order = StalnoyRules.rules_parse(@vendor.rows, "on_order")
          @rules = JSON.parse @vendor.rows
        else
          @rules = Hash["item_code" => "!=:nil", "price" => "<:0", "available" => "nil", "unavailable" => "nil", "on_order" => "nil", "white_space" => "false"]
        end


        ((params[:size] != nil) ? params[:size].to_i : 50).times do |i|

          @preset << [
              @data[i][@template["item_code"].to_i],
              (@rules["white_space"] == 'true') ? @data[i][@template["price"].to_i].to_s.sub(',', '').to_f : (@rules["white_space"] == 'false') ? @data[i][@template["price"].to_i].to_s.sub(',', '.').to_f : @data[i][@template["price"].to_i].to_f,
              @data[i][@template["available"].to_i]
          ]
        end

      end

      def cols
        @vendor = Spree::StalnoyImport.find(params[:id])
        @data = ActiveSupport::JSON.decode(@vendor.data).to_a[0][1] if Spree::StalnoyImport.exists?(params[:id])
        @preset = []
        @width = 0
        ((params[:size] != nil) ? params[:size].to_i : 50).times {|i| @preset << @data[i]; @width = @data[i].count if @data[i].count >= @width}


        if @vendor.cols.nil?
          @template = Hash["width" => @width, "item_code" => "0", "price" => "1", "available" => "2", "currency" => "$SOURCE"]
        else
          @template = ActiveSupport::JSON.decode(@vendor.cols)
        end


      end

      def setcols
        vendor = Spree::StalnoyImport.find(params[:id])
        respond_to do |f|
          if vendor.update(cols: (params.permit(:width, :item_code, :price, :currency, :available)).to_json) then
            f.html {redirect_to admin_vcols_path(vendor), notice: Spree.t(:updating_vendor_seccessful, scope: :stalnoy_import)}
          else
            f.html {redirect_to admin_vcols_path(vendor), notice: Spree.t(:updating_vendor_failed, scope: :stalnoy_import)}
          end
        end
      end

      def setrows
        vendor = Spree::StalnoyImport.find(params[:id])
        respond_to do |f|
          if vendor.update(rows: (params.permit(:item_code, :price, :currency, :available, :unavailable, :on_order, :white_space)).to_json) then
            f.html {redirect_to admin_vrows_path(vendor), notice: Spree.t(:updating_vendor_seccessful, scope: :stalnoy_import)}
          else
            f.html {redirect_to admin_vrows_path(vendor), notice: Spree.t(:updating_vendor_failed, scope: :stalnoy_import)}
          end
        end
      end

      def hide_all

        Spree::Product.update_all(discontinue_on: Time.now)

      end

      def update_price
        # @vendor = Spree::StalnoyImport.find(params[:id])
        # unless params[:id].nil?
        #   data = ActiveSupport::JSON.decode(@vendor.data_prepared).to_a
        #   data.each_with_index do |row, index|
        #     variant = Spree::Variant.find_by(sku: row[0])
        #     unless variant.nil?
        #       variant.update(price: row[1].to_d,cost_currency:'USD',discontinue_on: Time.now + 14.day)
        #     end
        #   end
        # end
        Rails.logger.error 'update_price depricated'
      end


    end
  end
end
