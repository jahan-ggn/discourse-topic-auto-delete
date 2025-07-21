import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import TopicAutoDeleteTimer from "../../components/topic-auto-delete-timer";

export default class ComposerTopicAutoDeleteTimer extends Component {
  @service composer;

  fieldName = "auto_delete_after_minutes";

  constructor() {
    super(...arguments);
    if (
      !this.composer.model[this.fieldName] &&
      this.composer.model.topic &&
      this.composer.model.topic[this.fieldName]
    ) {
      this.composer.model.set(
        this.fieldName,
        this.composer.model.topic[this.fieldName]
      );
    }
    this.mins = this.composer.model.get(this.fieldName);
  }

  @action
  onFieldChange(mins) {
    this.composer.model.set(this.fieldName, mins);
  }

  <template>
    <TopicAutoDeleteTimer
      @durationMinutes={{this.mins}}
      @onChange={{this.onFieldChange}}
    />
  </template>
}
