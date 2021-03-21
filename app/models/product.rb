class Product < ApplicationRecord
  require 'open-uri'

  belongs_to :rt, optional: true
  belongs_to :dr, optional: true

  scope :product_all_size, -> { order(:id).size }
  scope :product_qt_not_null, -> { where('quantity > 0') }
  scope :product_qt_not_null_size, -> { where('quantity > 0').size }
  scope :product_cat, -> { order('cat DESC').select(:cat).uniq }
  scope :product_image_nil, -> { where(image: [nil, '']).order(:id) }

  validate :new_distributor_empty, on: :update

  def new_distributor_empty
    if rt_id.present?
      rt = Rt.find_by(id: rt_id)
      if rt.nil? || (rt.product.present? && rt.product != self)
        errors.add(:rt_id, "Товар поставщика не существует или он уже связан с другим товаром")
      end
    end

    if dr_id.present?
      dr = Dr.find_by(id: dr_id)
      if dr.nil? || (dr.product.present? && dr.product != self)
        errors.add(:dr_id, "Товар поставщика не существует или он уже связан с другим товаром")
      end
    end
  end

  def self.export_api
    products = Product.where.not(rt: nil).or(Product.where.not(dr: nil))

    products.each do |product|
      puts "start update_var_info Товар id - #{product.id} Время - #{Time.zone.now}"

      api_key = "8d8c1bfc2a3ce24ae562bdbc2547abda"
      password = "0f5bf9c1f62cc99230b8ec4a7fc8f055"
      domain = "demo-themes.myinsales.ru"

      update_var_url = "http://#{api_key}:#{password}@#{domain}/admin/products/#{product.insales_id}/variants/#{product.insales_var_id}.json"
      var_data = {
        "variant": {
          "price": product.price,
          "quantity": product.quantity
        }
      }
      RestClient.put( update_var_url, var_data.to_json, :accept => :json, :content_type => "application/json") { |response, request, result, &block|
        case response.code
        when 200
          puts 'sleep 0.1 обновили вариант'
          sleep 0.1
        when 422
          puts "error 422 - не обновили вариант"
          puts response
          break
        when 404
          puts response
          puts 'error 404'
          break
        when 503
          sleep 1
          puts 'sleep 1 error 503'
        else
          response.return!(&block)
        end
      }

      puts "finish update_var_info Товар id - #{product.id} Время - #{Time.zone.now}"
    end
  end

  def self.linking
    Rt.find_each(batch_size: 1000) do |rt|
      product = Product.find_by(sku: rt.sku)
      rt.product = product if product.present?
      rt.save
    end

    Dr.find_each(batch_size: 1000) do |dr|
      product = Product.find_by(sku: dr.sku)
      dr.product = product if product.present?
      dr.save
    end
  end

  def self.syncronaize
    Product.find_each(batch_size: 1000) do |product|
      rt = product.rt
      dr = product.dr

      product.price = ("#{rt&.price ? rt.price : 0}".to_f + "#{dr&.price ? dr.price : 0}".to_f) / 2
      product.quantity = "#{rt&.quantity ? rt.quantity : 0}".to_i + "#{dr&.quantity ? dr.quantity : 0}".to_i
      product.save
    end
  end

  def self.update_price_quantity_all_providers
    Product.import_insales_xml
    # Здесь будут синхронизации всех поставщиков
    Product.linking
    Product.syncronaize
    Product.export_api
  end

  def self.import_insales_xml
    puts '=====>>>> СТАРТ InSales YML '+Time.now.to_s
    uri = "https://demo-themes.myinsales.ru/marketplace/76801.xml"
    response = RestClient.get uri, :accept => :xml, :content_type => "application/xml"
    data = Nokogiri::XML(response)
    mypr = data.xpath("//offer")

    categories = {}
    doc_category = data.xpath("//category")

    doc_category.each do |c|
      categories[c["id"]] = c.text
    end


    mypr.each do |pr|
    params = {}
    pr.xpath("param").each do |p|
      params[p['name']] = p.text
    end

      data_create = {
        sku: pr.xpath("vendorCode").text,
        title: pr.xpath("model").text,
        url: pr.xpath("url").text,
        desc: pr.xpath("description").text,
        image: pr.xpath("picture").map(&:text).join(' '),
        cat: categories[pr.xpath("categoryId").text],
        price: pr.xpath("price").text.to_f,
        oldprice: pr.xpath("oldprice").text.to_f,
        weight: pr.xpath("weight").text,
        color: params['Цвет'],
        size: params['Размер'],
        distributor: params['Поставщик'],
        insales_id: pr["group_id"],
        insales_var_id: pr["id"]
      }

      data_update = {
        title: pr.xpath("model").text,
        url: pr.xpath("url").text,
        desc: pr.xpath("description").text,
        image: pr.xpath("picture").map(&:text).join(' '),
        cat: categories[pr.xpath("categoryId").text],
        price: pr.xpath("price").text.to_f,
        oldprice: pr.xpath("oldprice").text.to_f,
        weight: pr.xpath("weight").text,
        color: params['Цвет'],
        size: params['Размер'],
        distributor: params['Поставщик']
      }
      product = Product
                  .find_by(insales_var_id: data_create[:insales_var_id])

      product.present? ? product.update_attributes(data_update) : Product.create(data_create)
    end
    puts '=====>>>> FINISH InSales YML '+Time.now.to_s
  end

  def self.open_spreadsheet(path_file, extend_file)
    case extend_file
    when ".csv" then Roo::Spreadsheet.open(path_file, { csv_options: { encoding: 'bom|utf-8', col_sep: "\t" } })
      # when ".csv" then Roo::CSV.new(file.path)
      # when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: "\t"})
    when ".xls" then Roo::Excel.new(path_file)
    when ".xlsx" then Roo::Excelx.new(path_file)
    when ".XLS" then Roo::Excel.new(path_file)
    else raise "Unknown file type"
    end
  end

  def self.create_csv
    file = "#{Rails.root}/public/export_insales.csv"
    check = File.file?(file)
    if check.present?
      File.delete(file)
    end

    products = Product.where.not(provider: nil).where.not(productid_provider: nil).order(:id)

    CSV.open("#{Rails.root}/public/export_insales.csv", "wb") do |writer|
      headers = [ 'ID варианта товара', 'Артикул', 'Название товара', 'Цена продажи', 'Цена закупки', 'Склад Удаленный' ]

      writer << headers
      products.each do |pr|
          productid_var_insales = pr.productid_var_insales
          title = pr.title
          sku = pr.sku
          price = pr.price
          provider_price = pr.provider_price
          store = pr.quantity

          writer << [productid_var_insales, sku, title, price, provider_price, store]
      end
    end #CSV.open
  end

end
