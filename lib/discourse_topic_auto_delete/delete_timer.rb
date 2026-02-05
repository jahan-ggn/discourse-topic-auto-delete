# frozen_string_literal: true

module DiscourseTopicAutoDelete
  class DeleteTimer
    def self.set_for(topic, user)
      return if topic.blank?
      return unless user&.staff? || user&.id == topic.user_id

      allowed_ids = SiteSetting.auto_delete_enabled_category_ids.to_s.split("|").map(&:to_i)
      category_allowed = allowed_ids.include?(topic.category_id)

      duration_minutes = topic.custom_fields["auto_delete_after_minutes"]

      unless category_allowed
        if topic.custom_fields.key?("auto_delete_after_minutes")
          topic.custom_fields.delete("auto_delete_after_minutes")
          topic.save_custom_fields
        end

        TopicTimer.where(topic: topic, status_type: TopicTimer.types[:delete]).destroy_all
        return
      end

      return if duration_minutes.blank?

      options = { by_user: user, duration_minutes: duration_minutes.to_i }

      time = (Time.zone.now + duration_minutes.to_i.minutes).strftime("%Y-%m-%d %H:%M:%S")

      begin
        topic.set_or_create_timer(TopicTimer.types[:delete], time, **options)
      rescue => e
        Rails.logger.error("Error setting delete timer: #{e.message}")
      end
    end
  end
end
