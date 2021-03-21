class RtImportInsalesJob < ApplicationJob
  queue_as :default

  def perform(path_file, extend_file)
    Rt.import_insales(path_file, extend_file)

    ActionCable.server.broadcast 'finish_process', {process_name: "Обновление RT Товаров"}
  end
end
