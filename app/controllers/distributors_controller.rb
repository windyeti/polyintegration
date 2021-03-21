class DistributorsController < ApplicationController
  before_action :load_provider, only: [:show, :edit, :update, :destroy, :import, :syncronaize]

  # authorize_resource

  def index
    @distributors = Distributor.all
  end

  def new
    @distributor = Distributor.new
  end

  def create
    @distributor = Distributor.new(params_provider)
    if @distributor.save
      redirect_to providers_path, notice: "Поставщик создан"
    else
      flash.now[:alert] = "Поставщик не создан"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @distributor.update(params_distributor)
      redirect_to @distributor, notice: "Поставщик изменен"
    else
      flash.now[:alert] = "Поставщик не изменен"
      render :edit
    end
  end

  def destroy
    @distributor.destroy
    redirect_to providers_path
  end


  private

  def load_provider
    @distributor = Distributor.find(params[:id])
  end

  def params_distributor
    params.require(:distributor).permit(:name, :prefix, :link, :permalink)
  end
end
