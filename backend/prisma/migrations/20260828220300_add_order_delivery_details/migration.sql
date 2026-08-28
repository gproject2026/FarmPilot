DO $$
BEGIN
  CREATE TYPE "DeliveryMethod" AS ENUM ('PICKUP', 'DELIVERY');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE "PaymentMethod" AS ENUM ('CASH');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE "orders"
  ADD COLUMN IF NOT EXISTS "delivery_method" "DeliveryMethod",
  ADD COLUMN IF NOT EXISTS "payment_method" "PaymentMethod" DEFAULT 'CASH',
  ADD COLUMN IF NOT EXISTS "delivery_address" TEXT,
  ADD COLUMN IF NOT EXISTS "pickup_location" TEXT;

UPDATE "orders"
SET "delivery_method" = 'PICKUP'
WHERE "delivery_method" IS NULL;

UPDATE "orders"
SET "payment_method" = 'CASH'
WHERE "payment_method" IS NULL;

ALTER TABLE "orders"
  ALTER COLUMN "delivery_method" SET NOT NULL,
  ALTER COLUMN "payment_method" SET NOT NULL;

ALTER TABLE "orders"
  ALTER COLUMN "delivery_method" DROP DEFAULT;