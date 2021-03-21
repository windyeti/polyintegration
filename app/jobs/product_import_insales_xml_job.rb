class ProductImportInsalesXmlJob < ApplicationJob
  queue_as :default

  def perform
    Product.import_insales_xml

    ActionCable.server.broadcast 'finish_process', {process_name: "Обновление Товаров InSales"}
  end
end
