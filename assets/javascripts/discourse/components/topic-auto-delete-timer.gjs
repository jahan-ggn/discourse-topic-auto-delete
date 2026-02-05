import Component from "@ember/component";
import EmberObject, { action } from "@ember/object";
import { service } from "@ember/service";
import PopupInputTip from "discourse/components/popup-input-tip";
import RelativeTimePicker from "discourse/components/relative-time-picker";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

export default class TopicAutoDeleteTimer extends Component {
  @service composer;
  @service siteSettings;

  auto_delete_after_minutes = null;

  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);
    if (this.shouldRender) {
      this.set("auto_delete_after_minutes", this.durationMinutes);
    }
  }

  @discourseComputed("auto_delete_after_minutes", "composer.lastValidatedAt")
  validation(auto_delete_after_minutes, lastValidatedAt) {
    if (!auto_delete_after_minutes || auto_delete_after_minutes <= 0) {
      return EmberObject.create({
        failed: true,
        reason: i18n(
          "discourse_topic_auto_delete.topic.auto-delete.validation_error"
        ),
        lastShownAt: lastValidatedAt,
      });
    }
    return null;
  }

  get allowedCategoryIds() {
    if (!this.siteSettings.auto_delete_enabled_category_ids) {
      return [];
    }
    return this.siteSettings.auto_delete_enabled_category_ids
      .split("|")
      .map((id) => parseInt(id, 10))
      .filter(Boolean);
  }

  get shouldRender() {
    const model = this.composer.model;
    const categoryId = model?.category?.id;

    if (!categoryId || !this.allowedCategoryIds.includes(categoryId)) {
      return false;
    }

    // New topic
    if (model.action === "createTopic") {
      return true;
    }

    // Editing the first post
    if (model.action === "edit" && model.post?.post_number === 1) {
      return true;
    }

    return false;
  }

  @action
  onFieldChange(minutes) {
    if (this.onChange) {
      this.onChange(minutes);
    }
  }

  <template>
    {{#if this.shouldRender}}
      <div class="topic-timer-wrapper">
        <label for="topic-auto-delete">
          {{i18n "discourse_topic_auto_delete.topic.auto-delete.label"}}
        </label>

        <PopupInputTip @validation={{this.validation}} />

        <RelativeTimePicker
          @id="topic-timer-auto-delete"
          @durationMinutes={{this.auto_delete_after_minutes}}
          @onChange={{this.onFieldChange}}
        />
      </div>
    {{/if}}
  </template>
}
