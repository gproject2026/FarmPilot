import 'dotenv/config';

import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error('DATABASE_URL is not defined');
}

const adapter = new PrismaPg({
  connectionString: databaseUrl,
});

const prisma = new PrismaClient({
  adapter,
});

async function main() {
  const categories = [
    {
      name: 'Vegetables',
      description: 'Fresh vegetables and vegetable products',
    },
    {
      name: 'Fruits',
      description: 'Fresh fruits and fruit products',
    },
    {
      name: 'Herbs',
      description: 'Fresh and dried herbs',
    },
    {
      name: 'Honey',
      description: 'Honey and beekeeping products',
    },
    {
      name: 'Dairy Products',
      description: 'Milk, cheese, yogurt, and dairy products',
    },
    {
      name: 'Eggs',
      description: 'Fresh farm eggs',
    },
    {
      name: 'Olive Oil',
      description: 'Olive oil and olive products',
    },
    {
      name: 'Grains',
      description: 'Wheat, barley, corn, and grains',
    },
    {
      name: 'Legumes',
      description: 'Beans, lentils, chickpeas, and legumes',
    },
    {
      name: 'Nuts',
      description: 'Fresh and dried nuts',
    },
    {
      name: 'Seeds',
      description: 'Agricultural and edible seeds',
    },
    {
      name: 'Plants and Seedlings',
      description: 'Plants, flowers, and seedlings',
    },
    {
      name: 'Spices',
      description: 'Natural spices and seasonings',
    },
    {
      name: 'Mushrooms',
      description: 'Fresh and dried mushrooms',
    },
    {
      name: 'Animal Feed',
      description: 'Feed products for farm animals',
    },
    {
      name: 'Poultry Products',
      description: 'Chicken and poultry products',
    },
    {
      name: 'Meat Products',
      description: 'Farm meat products',
    },
    {
      name: 'Homemade Products',
      description: 'Traditional homemade products',
    },
    {
      name: 'Preserves and Pickles',
      description: 'Pickles, jams, and preserves',
    },
    {
      name: 'Organic Products',
      description: 'Organic agricultural products',
    },
    {
      name: 'Other',
      description: 'Other agricultural products',
    },
  ];

  for (const category of categories) {
    const existingCategory =
      await prisma.category.findFirst({
        where: {
          name: {
            equals: category.name,
            mode: 'insensitive',
          },
        },
      });

    if (!existingCategory) {
      await prisma.category.create({
        data: category,
      });
    }
  }

  console.log('Categories seeded successfully.');
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });