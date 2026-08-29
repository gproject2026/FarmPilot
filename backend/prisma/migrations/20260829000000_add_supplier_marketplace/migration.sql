-- AlterEnum
ALTER TYPE "UserRole" ADD VALUE 'SUPPLIER';


CREATE TABLE "supplier_categories" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "name_en" VARCHAR(100),
    "name_ar" VARCHAR(100),
    "description_en" TEXT,
    "description_ar" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "supplier_categories_pkey" PRIMARY KEY ("id")
);


CREATE TABLE "supplier_products" (
    "id" UUID NOT NULL,
    "supplier_id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "name_en" VARCHAR(150),
    "name_ar" VARCHAR(150),
    "description_en" TEXT,
    "description_ar" TEXT,
    "planting_instructions" TEXT,
    "planting_instructions_en" TEXT,
    "planting_instructions_ar" TEXT,
    "irrigation_instructions" TEXT,
    "irrigation_instructions_en" TEXT,
    "irrigation_instructions_ar" TEXT,
    "usage_instructions" TEXT,
    "usage_instructions_en" TEXT,
    "usage_instructions_ar" TEXT,
    "price" DECIMAL(10,2) NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit" VARCHAR(30) NOT NULL,
    "image_url" TEXT,
    "status" "ProductStatus" NOT NULL DEFAULT 'AVAILABLE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "supplier_products_pkey" PRIMARY KEY ("id")
);


CREATE TABLE "supplier_orders" (
    "id" UUID NOT NULL,
    "farmer_id" UUID NOT NULL,
    "supplier_id" UUID NOT NULL,
    "total_price" DECIMAL(10,2) NOT NULL,
    "status" "OrderStatus" NOT NULL DEFAULT 'PENDING',
    "delivery_method" "DeliveryMethod" NOT NULL,
    "payment_method" "PaymentMethod" NOT NULL DEFAULT 'CASH',
    "delivery_address" TEXT,
    "pickup_location" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "supplier_orders_pkey" PRIMARY KEY ("id")
);


CREATE TABLE "supplier_order_items" (
    "id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "product_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "supplier_order_items_pkey" PRIMARY KEY ("id")
);


CREATE INDEX "supplier_products_supplier_id_idx" ON "supplier_products"("supplier_id");


CREATE INDEX "supplier_products_category_id_idx" ON "supplier_products"("category_id");


CREATE INDEX "supplier_orders_farmer_id_idx" ON "supplier_orders"("farmer_id");


CREATE INDEX "supplier_orders_supplier_id_idx" ON "supplier_orders"("supplier_id");


CREATE INDEX "supplier_order_items_order_id_idx" ON "supplier_order_items"("order_id");


CREATE INDEX "supplier_order_items_product_id_idx" ON "supplier_order_items"("product_id");


ALTER TABLE "supplier_products" ADD CONSTRAINT "supplier_products_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE "supplier_products" ADD CONSTRAINT "supplier_products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "supplier_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE "supplier_orders" ADD CONSTRAINT "supplier_orders_farmer_id_fkey" FOREIGN KEY ("farmer_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE "supplier_orders" ADD CONSTRAINT "supplier_orders_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE "supplier_order_items" ADD CONSTRAINT "supplier_order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "supplier_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE "supplier_order_items" ADD CONSTRAINT "supplier_order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "supplier_products"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

