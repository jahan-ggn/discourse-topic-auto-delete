# frozen_string_literal: true

DiscourseTopicAutoDelete::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw do
  mount ::DiscourseTopicAutoDelete::Engine, at: "discourse-topic-auto-delete"
end
