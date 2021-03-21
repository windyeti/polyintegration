class RtsController < ApplicationController

  authorize_resource

  def index
    @search = Rt.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @rts = @search.result.paginate(page: params[:page], per_page: 100)
    # if params['otchet_type'] == 'selected'
    #   Product.csv_param_selected( params['selected_products'], params['otchet_type'])
    #   new_file = "#{Rails.public_path}"+'/ins_detail_selected.csv'
    #   send_file new_file, :disposition => 'attachment'
    # end
  end

  def show
    @rt = Rt.find(params[:id])
  end

  def import_insales
    ActionCable.server.broadcast 'start_process', {process_name: "Обновление RT Товаров"}
    path_file = params[:file].path
    extend_file = File.extname(params[:file].original_filename)
    RtImportInsalesJob.perform_later(path_file, extend_file)
  end

  def unlinking_to_xls
    ActionCable.server.broadcast 'start_process', {process_name: "Создание Xls c незалинкованными RT товарами"}
    RtUnlinkToXlsJob.perform_later
  end
end
