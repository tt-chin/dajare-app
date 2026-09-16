import {FieldPath, Firestore} from "firebase-admin/firestore";
import {getDefaultFirestore} from "./firestore_client";

export const collectionRetentionLimit = 100;
export const cleanupBatchSize = 400;

// uid is supplied only by the authenticated callable, never by request.data.
export async function cleanupDajareEntries(
  uid: string,
  firestore: Firestore = getDefaultFirestore(() => {}),
): Promise<void> {
  const collection = firestore.collection(`users/${uid}/dajareEntries`);
  const newest = await collection.orderBy("createdAt", "desc")
    .orderBy(FieldPath.documentId(), "desc")
    .select("createdAt").limit(collectionRetentionLimit).get();
  if (newest.size < collectionRetentionLimit) return;

  const boundary = newest.docs[collectionRetentionLimit - 1];
  // Fixed boundary protects the newest 100 and any concurrently added entries.
  // Project only document references: child text is not needed for cleanup.
  const oldEntries = collection.orderBy("createdAt", "asc")
    .orderBy(FieldPath.documentId(), "asc")
    .endBefore(boundary.get("createdAt"), boundary.id)
    .select().limit(cleanupBatchSize);
  while (true) {
    const page = await oldEntries.get();
    if (page.empty) return;
    const batch = firestore.batch();
    for (const document of page.docs) batch.delete(document.ref);
    await batch.commit();
    if (page.size < cleanupBatchSize) return;
  }
}
