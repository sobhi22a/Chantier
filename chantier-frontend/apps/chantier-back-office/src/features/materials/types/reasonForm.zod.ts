import { z } from "zod";

const REASON_NOTE_MAX = 200;
export const OTHER_REASON = "Other";

// « Autre » impose une remarque (contrat, H-MAT-18) ; les listes de motifs viennent du serveur (GET /settings/materials).
export const reasonFormSchema = z
  .object({
    reasonCode: z.string().min(1, "materials:reason.required"),
    reasonNote: z.string().max(REASON_NOTE_MAX, "materials:reason.noteTooLong"),
  })
  .superRefine((values, context) => {
    if (values.reasonCode === OTHER_REASON && values.reasonNote.trim() === "") {
      context.addIssue({ code: "custom", path: ["reasonNote"], message: "materials:reason.noteRequired" });
    }
  });

export type ReasonFormValues = z.infer<typeof reasonFormSchema>;

export const toReasonBody = (values: ReasonFormValues) => ({
  reasonCode: values.reasonCode,
  reasonNote: values.reasonNote.trim() === "" ? null : values.reasonNote.trim(),
});
