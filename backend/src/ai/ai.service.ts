import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { MarketingDescriptionDto } from './dto/marketing-description.dto';

interface MarketingContent {
  title: string;
  description: string;
  keywords: string[];
  suggestions: string[];
}

@Injectable()
export class AiService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async generateMarketingDescription(
    farmerId: string,
    marketingDescriptionDto: MarketingDescriptionDto,
  ) {
    const productName =
      marketingDescriptionDto.productName.trim();

    const productDetails =
      marketingDescriptionDto.productDetails.trim();

    const targetAudience =
      marketingDescriptionDto.targetAudience
        ?.trim();

    const productId =
      marketingDescriptionDto.productId;

    if (productId) {
      await this.validateProductOwnership(
        productId,
        farmerId,
      );
    }

    const generatedContent =
      this.generateContent({
        productName,
        productDetails,
        targetAudience,
      });

    const marketingLog =
      await this.prisma.aIMarketingLog.create({
        data: {
          farmerId,
          productId,
          inputText: this.buildInputText({
            productName,
            productDetails,
            targetAudience,
          }),
          generatedTitle:
            generatedContent.title,
          generatedDescription:
            generatedContent.description,
          generatedKeywords:
            generatedContent.keywords.join(
              ', ',
            ),
          suggestions:
            generatedContent.suggestions.join(
              '\n',
            ),
        },
      });

    return {
      message:
        'Marketing content generated successfully',
      marketingLogId: marketingLog.id,
      title: generatedContent.title,
      description:
        generatedContent.description,
      keywords: generatedContent.keywords,
      suggestions:
        generatedContent.suggestions,
      createdAt: marketingLog.createdAt,
    };
  }

  private async validateProductOwnership(
    productId: string,
    farmerId: string,
  ) {
    const product =
      await this.prisma.product.findUnique({
        where: {
          id: productId,
        },
        select: {
          id: true,
          farmerId: true,
        },
      });

    if (!product) {
      throw new NotFoundException(
        'Product not found',
      );
    }

    if (product.farmerId !== farmerId) {
      throw new ForbiddenException(
        'You cannot generate marketing content for this product',
      );
    }
  }

  private generateContent(params: {
  productName: string;
  productDetails: string;
  targetAudience?: string;
}): MarketingContent {
  const {
    productName,
    productDetails,
    targetAudience,
  } = params;

  const cleanProductName =
    productName.trim();

  const normalizedProductName =
    cleanProductName.toLowerCase();

  const normalizedDetails =
    productDetails.toLowerCase();

  const audience =
    targetAudience &&
    targetAudience.trim().length > 0
      ? targetAudience.trim()
      : 'customers looking for fresh and reliable farm products';

  const normalizedAudience =
    audience.toLowerCase();

  const containsFresh =
    normalizedProductName.includes(
      'fresh',
    );

  const titleOptions = containsFresh
    ? [
        `Premium ${cleanProductName}`,
        `High Quality ${cleanProductName}`,
        `Locally Grown ${cleanProductName}`,
        `Farm Selected ${cleanProductName}`,
      ]
    : [
        `Fresh ${cleanProductName}`,
        `Premium ${cleanProductName}`,
        `Locally Grown ${cleanProductName}`,
        `Farm Fresh ${cleanProductName}`,
      ];

  const titleIndex =
    Date.now() % titleOptions.length;

  const title =
    titleOptions[titleIndex];

  const descriptionOptions = [
    `Bring freshness and dependable quality to your table with ${cleanProductName}. ` +
      `${productDetails}. ` +
      `This product is prepared for ${audience} and offers a convenient farm-to-customer experience through FarmPilot.`,

    `Choose ${cleanProductName} for a reliable combination of freshness, value, and quality. ` +
      `${productDetails}. ` +
      `It is a suitable choice for ${audience} who are looking for trusted local farm products.`,

    `Enjoy the natural quality of ${cleanProductName}. ` +
      `${productDetails}. ` +
      `Carefully offered for ${audience}, this product is a practical choice for customers who value freshness and dependable service.`,

    `Discover a better way to shop for ${cleanProductName}. ` +
      `${productDetails}. ` +
      `FarmPilot connects ${audience} with quality farm products in a simple and convenient way.`,
  ];

  const descriptionIndex =
    Date.now() % descriptionOptions.length;

  const description =
    descriptionOptions[
      descriptionIndex
    ];

  const keywords =
    this.generateKeywords(
      cleanProductName,
      productDetails,
    );

  const suggestions: string[] = [
    'Use a clear and well-lit image that shows the real product.',
    'Mention the available quantity, unit, and expected availability.',
    'Highlight the product origin, freshness, and harvesting method.',
    'Keep the price clear and competitive.',
    'Update the product stock regularly.',
  ];

  if (
    normalizedDetails.includes(
      'daily',
    )
  ) {
    suggestions.push(
      'Emphasize that the product is harvested or prepared daily.',
    );
  }

  if (
    normalizedDetails.includes(
      'organic',
    )
  ) {
    suggestions.push(
      'Highlight the organic growing method in the product title and description.',
    );
  }

  if (
    normalizedDetails.includes(
      'local',
    )
  ) {
    suggestions.push(
      'Promote the product as locally grown to attract nearby customers.',
    );
  }

  if (
    normalizedAudience.includes(
      'restaurant',
    )
  ) {
    suggestions.push(
      'Offer bulk quantity options for restaurants and food businesses.',
    );
  }

  return {
    title,
    description,
    keywords,
    suggestions,
  };
}

  private generateKeywords(
    productName: string,
    productDetails: string,
  ) {
    const ignoredWords = new Set([
      'and',
      'the',
      'with',
      'from',
      'this',
      'that',
      'your',
      'for',
      'are',
      'our',
      'was',
      'have',
      'has',
      'product',
    ]);

    const detailWords = productDetails
      .toLowerCase()
      .replace(
        /[^a-z0-9\s-]/g,
        ' ',
      )
      .split(/\s+/)
      .filter(
        (word) =>
          word.length >= 4 &&
          !ignoredWords.has(word),
      );

    const uniqueDetailWords = [
      ...new Set(detailWords),
    ].slice(0, 4);

    return [
      productName.toLowerCase(),
      ...uniqueDetailWords,
      'fresh produce',
      'farm product',
      'local farming',
      'high quality',
      'FarmPilot',
    ];
  }

  private buildInputText(params: {
    productName: string;
    productDetails: string;
    targetAudience?: string;
  }) {
    const {
      productName,
      productDetails,
      targetAudience,
    } = params;

    return [
      `Product name: ${productName}`,
      `Product details: ${productDetails}`,
      `Target audience: ${
        targetAudience ?? 'General customers'
      }`,
    ].join('\n');
  }
}