module ProductsHelper
  def selected(product)
    providers = Provider.all.order(:id)
    providers.each do |provider|
      return provider.permalink if provider.permalink == product.productable_type
    end
  end

  # TODO NewDistributor
  def distributor_product_id_quantity(product)
    result = {
      available: false,
      html: ''
    }
    result[:available] = true if product.rt || product.dr

    result[:html] += "<p>RT: ID: #{product.rt.id}, остаток: #{product.rt.quantity}, цена: #{product.rt.price}</p>" if product.rt.present?
    result[:html] += "<p>DR: ID: #{product.dr.id}, остаток: #{product.dr.quantity}, цена: #{product.dr.price}</p>" if product.dr.present?
    result
  end
end
