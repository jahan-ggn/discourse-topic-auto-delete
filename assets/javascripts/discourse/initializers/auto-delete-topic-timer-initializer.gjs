import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.serializeOnCreate("auto_delete_after_minutes");
  api.serializeToDraft("auto_delete_after_minutes");
  api.serializeToTopic(
    "auto_delete_after_minutes",
    "topic.auto_delete_after_minutes"
  );

  api.registerValueTransformer(
    "composer-service-cannot-submit-post",
    ({ context: { model } }) => {
      const auto_delete_after_minutes = model.auto_delete_after_minutes;

      if (!auto_delete_after_minutes || auto_delete_after_minutes <= 0) {
        return true;
      }

      return false;
    }
  );
});
