-- AlterTable
ALTER TABLE "reminders" ADD COLUMN     "crop_name" VARCHAR(100),
ADD COLUMN     "title" VARCHAR(100),
ALTER COLUMN "type" SET DEFAULT 'OTHER';
