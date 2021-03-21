class RtUnlinkToXlsJob < ApplicationJob
  queue_as :default

  def perform
    Rt.unlinking_to_xls

    ActionCable.server.broadcast 'finish_process', {process_name: "Создание Xls c незалинкованными RT товарами"}
  end
end
