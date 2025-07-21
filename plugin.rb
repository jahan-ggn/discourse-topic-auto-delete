# frozen_string_literal: true

# name: discourse-topic-auto-delete
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_topic_auto_delete_enabled

module ::DiscourseTopicAutoDelete
  PLUGIN_NAME = "discourse-topic-auto-delete"
end

require_relative "lib/discourse_topic_auto_delete/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
