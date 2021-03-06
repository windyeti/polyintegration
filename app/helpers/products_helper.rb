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

    result[:html] += "<p>RT: ID: <a href=/rts?q%5Bid_eq%5D=#{product.rt.id}>#{product.rt.id}</a>, остаток: #{product.rt.quantity}, цена: #{product.rt.price}</p>" if product.rt.present?
    result[:html] += "<p>DR: ID: <a href=/drs?q%5Bid_eq%5D=#{product.dr.id}>#{product.dr.id}</a>, остаток: #{product.dr.quantity}, цена: #{product.dr.price}</p>" if product.dr.present?
    # result[:html] += "<p>RT: ID: <a href=/rts?q[id_eq]=#{product.rt.id}>#{product.rt.id}</a>, остаток: #{product.rt.quantity}, цена: #{product.rt.price}</p>" if product.rt.present?
    # result[:html] += "<p>DR: ID: <a href=/drs?q[id_eq]=#{product.dr.id}>#{product.dr.id}</a>, остаток: #{product.dr.quantity}, цена: #{product.dr.price}</p>" if product.dr.present?
    result
  end
end
