class DrUnlinkToXlsJob < ApplicationJob
  queue_as :default

  def perform
    Dr.unlinking_to_xls

    ActionCable.server.broadcast 'finish_process', {process_name: "Создание Xls c незалинкованными DR товарами"}
  end
end
