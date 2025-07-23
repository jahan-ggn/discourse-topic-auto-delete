import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const siteSettings = api.container.lookup("service:site-settings");
  const enabledCategoryIds = siteSettings.auto_delete_enabled_category_ids
    .split("|")
    .map((id) => parseInt(id, 10));

  api.serializeOnCreate("auto_delete_after_minutes");
  api.serializeToDraft("auto_delete_after_minutes");
  api.serializeToTopic(
    "auto_delete_after_minutes",
    "topic.auto_delete_after_minutes"
  );

  api.registerValueTransformer(
    "composer-service-cannot-submit-post",
    ({ context: { model } }) => {
      const categoryId = model.topic?.category_id;

      if (!enabledCategoryIds.includes(categoryId)) {
        return false;
      }

      const auto_delete_after_minutes = model.auto_delete_after_minutes;

      if (!auto_delete_after_minutes || auto_delete_after_minutes <= 0) {
        return true;
      }

      return false;
    }
  );
});
