-- AlterTable
ALTER TABLE "crops" ADD COLUMN     "area" DECIMAL(10,2),
ADD COLUMN     "area_unit" VARCHAR(20),
ADD COLUMN     "expected_yield_max" DECIMAL(10,2),
ADD COLUMN     "expected_yield_min" DECIMAL(10,2),
ADD COLUMN     "yield_confidence" VARCHAR(20),
ADD COLUMN     "yield_unit" VARCHAR(20);
