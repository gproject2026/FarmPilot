ALTER TABLE "crops"
  ALTER COLUMN "irrigation_schedule" TYPE TEXT,
  ALTER COLUMN "irrigation_schedule_en" TYPE TEXT,
  ALTER COLUMN "irrigation_schedule_ar" TYPE TEXT,
  ALTER COLUMN "fertilization_schedule" TYPE TEXT,
  ALTER COLUMN "fertilization_schedule_en" TYPE TEXT,
  ALTER COLUMN "fertilization_schedule_ar" TYPE TEXT,
  ADD COLUMN "spraying_schedule" TEXT,
  ADD COLUMN "spraying_schedule_en" TEXT,
  ADD COLUMN "spraying_schedule_ar" TEXT;