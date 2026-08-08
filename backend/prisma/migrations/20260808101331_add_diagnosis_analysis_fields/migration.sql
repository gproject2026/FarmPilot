-- AlterTable
ALTER TABLE "diagnoses" ADD COLUMN     "is_healthy" BOOLEAN,
ADD COLUMN     "is_image_clear" BOOLEAN,
ADD COLUMN     "is_plant" BOOLEAN,
ADD COLUMN     "needs_expert_review" BOOLEAN,
ADD COLUMN     "severity" VARCHAR(30),
ADD COLUMN     "visible_symptoms" TEXT;
