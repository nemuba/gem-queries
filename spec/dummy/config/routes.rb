Rails.application.routes.draw do
  mount Queries::Engine => "/queries"
end
