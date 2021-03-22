class Dr < ApplicationRecord
  has_one :product

  scope :product_all_size, -> { order(:id).size }
  scope :product_qt_not_null, -> { where('quantity > 0') }
  scope :product_qt_not_null_size, -> { where('quantity > 0').size }
  # scope :product_cat, -> { order('cat DESC').select(:cat).uniq }
  scope :product_image_nil, -> { where(image: [nil, '']).order(:id) }

  def self.import_insales(path_file, extend_file)
    puts '=====>>>> СТАРТ YML '+Time.now.to_s
    Dr.all.each do |dr|
      dr.update(quantity: 0)
    end

    spreadsheets = open_spreadsheet(path_file, extend_file)
    last_spreadsheet = spreadsheets.last_row.to_i

    (2..last_spreadsheet).each do |i|
      data = {
        sku: spreadsheets.cell(i, 'E'),
        title: spreadsheets.cell(i, 'A'),
        desc: spreadsheets.cell(i, 'B'),
        quantity: spreadsheets.cell(i, 'I').to_i,
        price: spreadsheets.cell(i, 'F').to_f,
      }

      product = Dr
                  .find_by(sku: data[:sku])

      product.present? ? product.update(data) : Dr.create(data)
    end
    puts '=====>>>> FINISH YML '+Time.now.to_s
  end

  def self.unlinking_to_xls
    file = "#{Rails.root}/public/drs_unlinking.xls"

    check = File.file?(file)
    if check.present?
      File.delete(file)
    end

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet(name: 'DR незалинкованные')
    sheet.row(0).push("ID", "ID в таблице Товаров", "Артикул", "Название", "Остаток", "Цена", "Описание", "Параметры")

    products = Product.all.map(&:dr_id).reject(&:nil?)
    rts_unlinks = Dr.where('id not in (?)', products)

    rts_unlinks.each_with_index do |pr, index|
      id = pr[:id]
      productid_product = ''
      vendorcode = pr[:sku]
      title = pr[:title]
      quantity = pr[:quantity]
      price = pr[:price]
      desc = pr[:desc]
      param = pr[:param]

      sheet.row(index + 1).push(
        id,
        productid_product,
        vendorcode,
        title,
        quantity,
        price,
        desc,
        param
      )
    end

    book.write file
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
end
