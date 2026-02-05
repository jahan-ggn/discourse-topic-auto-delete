# frozen_string_literal: true

# name: discourse-topic-auto-delete
# about: Plugin to set auto-delete duration for topics
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/discourse-topic-auto-delete
# required_version: 2.7.0

enabled_site_setting :discourse_topic_auto_delete_enabled
register_asset "stylesheets/common.scss"

module ::DiscourseTopicAutoDelete
  PLUGIN_NAME = "discourse-topic-auto-delete"
end

require_relative "lib/discourse_topic_auto_delete/engine"
require_relative "lib/discourse_topic_auto_delete/delete_timer"

after_initialize do
  module ::TopicAutoDeleteField
    FIELD_NAME = "auto_delete_after_minutes"
    FIELD_TYPE = "integer"
  end

  register_topic_custom_field_type(
    TopicAutoDeleteField::FIELD_NAME,
    TopicAutoDeleteField::FIELD_TYPE,
  )

  add_to_class(:topic, TopicAutoDeleteField::FIELD_NAME.to_sym) do
    custom_fields[TopicAutoDeleteField::FIELD_NAME].presence
  end

  add_to_class(:topic, "#{TopicAutoDeleteField::FIELD_NAME}=") do |value|
    custom_fields[TopicAutoDeleteField::FIELD_NAME] = value
  end

  on(:topic_created) do |topic, opts, user|
    duration = opts[TopicAutoDeleteField::FIELD_NAME.to_sym]
    allowed_ids = SiteSetting.auto_delete_enabled_category_ids.to_s.split("|").map(&:to_i)

    if duration.present? && allowed_ids.include?(topic.category_id)
      topic.send("#{TopicAutoDeleteField::FIELD_NAME}=", duration)
      topic.save!
      ::DiscourseTopicAutoDelete::DeleteTimer.set_for(topic, user)
    else
      topic.custom_fields.delete(TopicAutoDeleteField::FIELD_NAME)
      topic.save_custom_fields
    end
  end

  PostRevisor.track_topic_field(TopicAutoDeleteField::FIELD_NAME.to_sym) do |tc, value|
    old_value = tc.topic.send(TopicAutoDeleteField::FIELD_NAME)

    tc.record_change(TopicAutoDeleteField::FIELD_NAME, old_value, value)
    tc.topic.send("#{TopicAutoDeleteField::FIELD_NAME}=", value.present? ? value : nil)

    if old_value != value && SiteSetting.discourse_topic_auto_delete_enabled
      tc.topic.save_custom_fields # Save BEFORE calling DeleteTimer
      ::DiscourseTopicAutoDelete::DeleteTimer.set_for(tc.topic, tc.user)
    end
  end

  add_to_serializer(:topic_view, TopicAutoDeleteField::FIELD_NAME.to_sym) do
    object.topic.send(TopicAutoDeleteField::FIELD_NAME)
  end

  add_preloaded_topic_list_custom_field(TopicAutoDeleteField::FIELD_NAME)
end
