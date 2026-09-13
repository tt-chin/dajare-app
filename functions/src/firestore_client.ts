import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {ReportStage} from "./diagnostics";

export function getDefaultFirestore(onStage: ReportStage) {
  onStage("admin_app_init");
  // The Functions SDK may already have a named app, but no default app.
  const app = getApps().find((candidate) => candidate.name === "[DEFAULT]") ??
    initializeApp();
  onStage("firestore_client_init");
  return getFirestore(app);
}
