import {
  BadGatewayException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CropCareSuggestionDto } from './dto/crop-care-suggestion.dto';
import { MarketingDescriptionDto } from './dto/marketing-description.dto';
import { GeminiService } from './gemini.service';

interface MarketingContent {
  title: string;
  description: string;
  keywords: string[];
  suggestions: string[];
}

interface CropCareContent {
  cropNameEn: string;
  cropNameAr: string;
  cropTypeEn: string;
  cropTypeAr: string;
  irrigationScheduleEn: string;
  irrigationScheduleAr: string;
  fertilizationScheduleEn: string;
  fertilizationScheduleAr: string;
}

@Injectable()
export class AiService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly geminiService: GeminiService,
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
      marketingDescriptionDto.targetAudience?.trim();

    const productId =
      marketingDescriptionDto.productId;

    const language =
      marketingDescriptionDto.language
        ?.trim()
        .toLowerCase() === 'ar'
        ? 'ar'
        : 'en';

    if (productId) {
      await this.validateProductOwnership(
        productId,
        farmerId,
      );
    }

    const generatedContent =
      await this.generateContentWithGemini({
        productName,
        productDetails,
        targetAudience,
        language,
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
            language,
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
        language === 'ar'
          ? 'تم إنشاء المحتوى التسويقي بنجاح'
          : 'Marketing content generated successfully',
      marketingLogId:
        marketingLog.id,
      title:
        generatedContent.title,
      description:
        generatedContent.description,
      keywords:
        generatedContent.keywords,
      suggestions:
        generatedContent.suggestions,
      createdAt:
        marketingLog.createdAt,
    };
  }

  async generateCropCareSuggestion(
    cropCareSuggestionDto: CropCareSuggestionDto,
  ) {
    const cropName =
      cropCareSuggestionDto.cropName.trim();

    const cropType =
      cropCareSuggestionDto.cropType.trim();

    const plantingDate =
      cropCareSuggestionDto.plantingDate?.trim();

    const notes =
      cropCareSuggestionDto.notes?.trim();

    const language =
      cropCareSuggestionDto.language === 'ar'
        ? 'ar'
        : 'en';

    const prompt = [
      'You are an agricultural assistant for FarmPilot.',
      '',
      'The farmer is adding or editing a crop.',
      'Your task is to provide bilingual crop information and practical general care suggestions.',
      '',
      `Crop name entered by farmer: ${cropName}`,
      `Crop type selected by farmer: ${cropType}`,
      `Planting date: ${plantingDate || 'Not provided'}`,
      `Additional notes: ${notes || 'Not provided'}`,
      '',
      'Requirements:',
      '- Identify the crop name in both English and Arabic.',
      '- Return the crop type in both English and Arabic.',
      '- Give a short and practical irrigation schedule in both English and Arabic.',
      '- Give a short and practical fertilization schedule in both English and Arabic.',
      '- Keep irrigation and fertilization suggestions concise enough to store in a database field.',
      '- Do not invent exact fertilizer quantities, pesticide dosages, or unsafe chemical instructions.',
      '- Do not claim the recommendation is universally correct.',
      '- Base the suggestions on common general agricultural practice.',
      '- The Arabic and English values must have the same meaning.',
      '- Do not use markdown.',
      '- Do not wrap the response in JSON code fences.',
      '',
      'Return ONLY valid JSON using exactly this structure:',
      '{',
      '  "cropNameEn": "string",',
      '  "cropNameAr": "string",',
      '  "cropTypeEn": "string",',
      '  "cropTypeAr": "string",',
      '  "irrigationScheduleEn": "string",',
      '  "irrigationScheduleAr": "string",',
      '  "fertilizationScheduleEn": "string",',
      '  "fertilizationScheduleAr": "string"',
      '}',
    ].join('\n');

    let responseText: string;

    try {
      responseText =
        await this.geminiService.generateText(
          prompt,
        );
    } catch (error) {
      console.error(
        'Gemini crop care generation error:',
        error,
      );

      throw new BadGatewayException(
        language === 'ar'
          ? 'تعذر إنشاء اقتراحات العناية بالمحصول باستخدام الذكاء الاصطناعي'
          : 'AI could not generate crop care suggestions',
      );
    }

    if (
      !responseText ||
      responseText.trim().length === 0
    ) {
      throw new BadGatewayException(
        language === 'ar'
          ? 'لم يُرجع الذكاء الاصطناعي اقتراحات للمحصول'
          : 'AI did not return crop care suggestions',
      );
    }

    const generatedContent =
      this.parseCropCareContent(
        responseText,
        language,
      );

    return {
      message:
        language === 'ar'
          ? 'تم إنشاء اقتراحات العناية بالمحصول بنجاح'
          : 'Crop care suggestions generated successfully',
      ...generatedContent,
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

    if (
      product.farmerId !== farmerId
    ) {
      throw new ForbiddenException(
        'You cannot generate marketing content for this product',
      );
    }
  }

  private async generateContentWithGemini(
    params: {
      productName: string;
      productDetails: string;
      targetAudience?: string;
      language: 'ar' | 'en';
    },
  ): Promise<MarketingContent> {
    const {
      productName,
      productDetails,
      targetAudience,
      language,
    } = params;

    const languageInstruction =
      language === 'ar'
        ? [
            'Write ALL generated marketing content in clear, natural Arabic.',
            'The title, description, keywords, and suggestions must all be in Arabic.',
            'Do not include English marketing words unless they are a brand name or unavoidable proper noun.',
            'Use simple Arabic suitable for farmers and general customers.',
          ].join(' ')
        : [
            'Write ALL generated marketing content in clear, natural English.',
            'The title, description, keywords, and suggestions must all be in English.',
            'Do not include Arabic words unless they are part of the original product name or a proper noun.',
          ].join(' ');

    const prompt = [
      'You are a marketing assistant for FarmPilot, a marketplace that connects farmers directly with customers.',
      '',
      languageInstruction,
      '',
      'Create useful and realistic marketing content for the following farm product.',
      '',
      `Product name: ${productName}`,
      `Product details: ${productDetails}`,
      `Target audience: ${
        targetAudience?.trim() ||
        (language === 'ar'
          ? 'العملاء الباحثون عن منتجات زراعية طازجة وموثوقة'
          : 'customers looking for fresh and reliable farm products')
      }`,
      '',
      'Requirements:',
      '- Create one attractive but realistic marketing title.',
      '- Create one concise marketing description.',
      '- Do not invent certifications, health claims, discounts, quantities, prices, or product qualities that were not provided.',
      '- Return between 5 and 8 useful keywords.',
      '- Return between 4 and 6 practical marketing suggestions.',
      '- Suggestions should help the farmer improve the product listing.',
      '- Keep the content suitable for an agricultural marketplace.',
      '- Do not use markdown.',
      '- Do not wrap the response in ```json code fences.',
      '',
      'Return ONLY valid JSON using exactly this structure:',
      '{',
      '  "title": "string",',
      '  "description": "string",',
      '  "keywords": ["string"],',
      '  "suggestions": ["string"]',
      '}',
    ].join('\n');

    let responseText: string;

    try {
      responseText =
        await this.geminiService.generateText(
          prompt,
        );
    } catch (error) {
      console.error(
        'Gemini marketing generation error:',
        error,
      );

      throw new BadGatewayException(
        language === 'ar'
          ? 'تعذر إنشاء المحتوى التسويقي باستخدام الذكاء الاصطناعي'
          : 'AI could not generate marketing content',
      );
    }

    if (
      !responseText ||
      responseText.trim().length === 0
    ) {
      throw new BadGatewayException(
        language === 'ar'
          ? 'لم يُرجع الذكاء الاصطناعي محتوى تسويقيًا'
          : 'AI did not return marketing content',
      );
    }

    return this.parseMarketingContent(
      responseText,
      language,
    );
  }

  private parseCropCareContent(
    responseText: string,
    language: 'ar' | 'en',
  ): CropCareContent {
    const cleanedResponse =
      this.cleanJsonResponse(
        responseText,
      );

    let parsed: unknown;

    try {
      parsed =
        JSON.parse(
          cleanedResponse,
        );
    } catch (error) {
      console.error(
        'Invalid Gemini crop care JSON:',
        responseText,
      );

      throw new BadGatewayException(
        language === 'ar'
          ? 'أعاد الذكاء الاصطناعي استجابة غير صالحة للمحصول'
          : 'AI returned an invalid crop care response',
      );
    }

    if (
      parsed === null ||
      typeof parsed !== 'object' ||
      Array.isArray(parsed)
    ) {
      throw new BadGatewayException(
        language === 'ar'
          ? 'أعاد الذكاء الاصطناعي استجابة غير صالحة للمحصول'
          : 'AI returned an invalid crop care response',
      );
    }

    const data =
      parsed as Record<
        string,
        unknown
      >;

    const cropNameEn =
      this.normalizeString(
        data.cropNameEn,
      );

    const cropNameAr =
      this.normalizeString(
        data.cropNameAr,
      );

    const cropTypeEn =
      this.normalizeString(
        data.cropTypeEn,
      );

    const cropTypeAr =
      this.normalizeString(
        data.cropTypeAr,
      );

    const irrigationScheduleEn =
      this.normalizeString(
        data.irrigationScheduleEn,
      );

    const irrigationScheduleAr =
      this.normalizeString(
        data.irrigationScheduleAr,
      );

    const fertilizationScheduleEn =
      this.normalizeString(
        data.fertilizationScheduleEn,
      );

    const fertilizationScheduleAr =
      this.normalizeString(
        data.fertilizationScheduleAr,
      );

    if (
      cropNameEn.length === 0 ||
      cropNameAr.length === 0 ||
      cropTypeEn.length === 0 ||
      cropTypeAr.length === 0 ||
      irrigationScheduleEn.length === 0 ||
      irrigationScheduleAr.length === 0 ||
      fertilizationScheduleEn.length === 0 ||
      fertilizationScheduleAr.length === 0
    ) {
      throw new BadGatewayException(
        language === 'ar'
          ? 'اقتراحات المحصول التي تم إنشاؤها غير مكتملة'
          : 'Generated crop care suggestions are incomplete',
      );
    }

    return {
      cropNameEn,
      cropNameAr,
      cropTypeEn,
      cropTypeAr,
      irrigationScheduleEn,
      irrigationScheduleAr,
      fertilizationScheduleEn,
      fertilizationScheduleAr,
    };
  }

  private parseMarketingContent(
    responseText: string,
    language: 'ar' | 'en',
  ): MarketingContent {
    const cleanedResponse =
      this.cleanJsonResponse(
        responseText,
      );

    let parsed: unknown;

    try {
      parsed =
        JSON.parse(
          cleanedResponse,
        );
    } catch (error) {
      console.error(
        'Invalid Gemini marketing JSON:',
        responseText,
      );

      throw new BadGatewayException(
        language === 'ar'
          ? 'أعاد الذكاء الاصطناعي استجابة غير صالحة'
          : 'AI returned an invalid marketing response',
      );
    }

    if (
      parsed === null ||
      typeof parsed !== 'object' ||
      Array.isArray(parsed)
    ) {
      throw new BadGatewayException(
        language === 'ar'
          ? 'أعاد الذكاء الاصطناعي استجابة غير صالحة'
          : 'AI returned an invalid marketing response',
      );
    }

    const data =
      parsed as Record<
        string,
        unknown
      >;

    const title =
      typeof data.title === 'string'
        ? data.title.trim()
        : '';

    const description =
      typeof data.description ===
      'string'
        ? data.description.trim()
        : '';

    const keywords =
      this.normalizeStringArray(
        data.keywords,
      );

    const suggestions =
      this.normalizeStringArray(
        data.suggestions,
      );

    if (
      title.length === 0 ||
      description.length === 0 ||
      keywords.length === 0 ||
      suggestions.length === 0
    ) {
      throw new BadGatewayException(
        language === 'ar'
          ? 'المحتوى الذي تم إنشاؤه غير مكتمل'
          : 'Generated marketing content is incomplete',
      );
    }

    return {
      title,
      description,
      keywords,
      suggestions,
    };
  }

  private normalizeString(
    value: unknown,
  ): string {
    return typeof value === 'string'
      ? value.trim()
      : '';
  }

  private normalizeStringArray(
    value: unknown,
  ): string[] {
    if (!Array.isArray(value)) {
      return [];
    }

    return value
      .filter(
        (item) =>
          typeof item === 'string',
      )
      .map(
        (item) =>
          (item as string).trim(),
      )
      .filter(
        (item) =>
          item.length > 0,
      );
  }

  private cleanJsonResponse(
    responseText: string,
  ) {
    let cleaned =
      responseText.trim();

    if (
      cleaned.startsWith('```')
    ) {
      cleaned =
        cleaned.replace(
          /^```(?:json)?\s*/i,
          '',
        );

      cleaned =
        cleaned.replace(
          /\s*```$/,
          '',
        );
    }

    const firstBrace =
      cleaned.indexOf('{');

    const lastBrace =
      cleaned.lastIndexOf('}');

    if (
      firstBrace !== -1 &&
      lastBrace !== -1 &&
      lastBrace > firstBrace
    ) {
      cleaned =
        cleaned.substring(
          firstBrace,
          lastBrace + 1,
        );
    }

    return cleaned.trim();
  }

  private buildInputText(
    params: {
      productName: string;
      productDetails: string;
      targetAudience?: string;
      language: 'ar' | 'en';
    },
  ) {
    const {
      productName,
      productDetails,
      targetAudience,
      language,
    } = params;

    return [
      `Product name: ${productName}`,
      `Product details: ${productDetails}`,
      `Target audience: ${
        targetAudience ??
        'General customers'
      }`,
      `Language: ${language}`,
    ].join('\n');
  }
}