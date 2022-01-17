require 'capybara/dsl'
require 'capybara/poltergeist'

class Services::ParsingJsSite
  include Capybara::DSL

  def call
    visit "https://yam.kz/naushniki-i-garnitury/professionalnye-garnitury/hd-450bt-ru/"
    # page.all(:css, ".ty-product-options__image--wrapper")[1].click
    # page.find(:css, "#features a").click
    # p page.find(:css, "#tabs_content").text
  end

end
