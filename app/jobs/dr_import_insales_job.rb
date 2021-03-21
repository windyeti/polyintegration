class DrImportInsalesJob < ApplicationJob
  queue_as :default

  def perform(path_file, extend_file)
    Dr.import_insales(path_file, extend_file)

    ActionCable.server.broadcast 'finish_process', {process_name: "Обновление DR Товаров"}
  end
end
