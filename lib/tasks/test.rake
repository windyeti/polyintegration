namespace :p do
  task capybara: :environment do
    Services::ParsingJsSite.new.call
  end
end
