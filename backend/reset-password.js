require('dotenv').config();

const bcrypt = require('bcrypt');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('DATABASE_URL is missing from the .env file');
  process.exit(1);
}

const adapter = new PrismaPg({
  connectionString: connectionString,
});

const prisma = new PrismaClient({
  adapter: adapter,
});

async function main() {
  const email = 'customer@test.com';
  const newPassword = '12345678';

  const existingUser = await prisma.user.findUnique({
    where: {
      email: email,
    },
  });

  if (!existingUser) {
    console.log(`User not found: ${email}`);
    return;
  }

  const hashedPassword = await bcrypt.hash(
    newPassword,
    10,
  );

  await prisma.user.update({
    where: {
      email: email,
    },
    data: {
      password: hashedPassword,
    },
  });

  const passwordMatches = await bcrypt.compare(
    newPassword,
    hashedPassword,
  );

  console.log('Password updated successfully');
  console.log('Email:', email);
  console.log('New password:', newPassword);
  console.log('Password verification:', passwordMatches);
}

main()
  .catch((error) => {
    console.error('Error while updating password:');
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });