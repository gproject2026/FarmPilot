-- AlterTable
ALTER TABLE "notifications" ADD COLUMN     "message_ar" TEXT,
ADD COLUMN     "message_en" TEXT,
ADD COLUMN     "title_ar" VARCHAR(150),
ADD COLUMN     "title_en" VARCHAR(150);
