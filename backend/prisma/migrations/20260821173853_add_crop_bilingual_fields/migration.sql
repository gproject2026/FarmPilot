-- AlterTable
ALTER TABLE "crops" ADD COLUMN     "crop_name_ar" VARCHAR(100),
ADD COLUMN     "crop_name_en" VARCHAR(100),
ADD COLUMN     "crop_type_ar" VARCHAR(100),
ADD COLUMN     "crop_type_en" VARCHAR(100),
ADD COLUMN     "fertilization_schedule_ar" VARCHAR(255),
ADD COLUMN     "fertilization_schedule_en" VARCHAR(255),
ADD COLUMN     "irrigation_schedule_ar" VARCHAR(255),
ADD COLUMN     "irrigation_schedule_en" VARCHAR(255),
ADD COLUMN     "notes_ar" TEXT,
ADD COLUMN     "notes_en" TEXT,
ALTER COLUMN "irrigation_schedule" SET DATA TYPE VARCHAR(255),
ALTER COLUMN "fertilization_schedule" SET DATA TYPE VARCHAR(255);
