module ProductsHelper
  def selected(product)
    providers = Provider.all.order(:id)
    providers.each do |provider|
      return provider.permalink if provider.permalink == product.productable_type
    end
  end

  def distributor_product_id_quantity(product)
    result = {
      available: false,
      html: ''
    }
    result[:available] = true if product.rt || product.dr

    result[:html] += "<p>RT: #{product.rt.id}, остаток: #{product.rt.quantity}</p>" if product.rt.present?
    result[:html] += "<p>DR: #{product.dr.id}, остаток: #{product.dr.quantity}</p>" if product.dr.present?
    result
  end
end
