module ProductsHelper
  def selected(product)
    providers = Provider.all.order(:id)
    providers.each do |provider|
      return provider.permalink if provider.permalink == product.productable_type
    end
  end
end
