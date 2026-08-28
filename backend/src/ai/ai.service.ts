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
  sprayingScheduleEn: string;
  sprayingScheduleAr: string;
  notesEn: string;
  notesAr: string;
  expectedYieldMin: number;
  expectedYieldMax: number;
  yieldUnit: string;
  yieldConfidence: 'LOW' | 'MEDIUM' | 'HIGH';
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

    const area =
      Number(cropCareSuggestionDto.area);

    const areaUnit =
      cropCareSuggestionDto.areaUnit.trim();

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
      'Your task is to provide bilingual crop information and practical general crop-care recommendations based on the cultivated area.',
      '',
      `Crop name entered by farmer: ${cropName}`,
      `Crop type selected by farmer: ${cropType}`,
      `Cultivated area: ${area} ${areaUnit}`,
      `Planting date: ${plantingDate || 'Not provided'}`,
      `Additional notes: ${notes || 'Not provided'}`,
      '',
      'Important area rule:',
      `- All irrigation, fertilization, spraying-volume, and yield recommendations must refer to the farmer's TOTAL cultivated area of ${area} ${areaUnit}.`,
      '- When giving a quantity, clearly state the total quantity for the full cultivated area, not only a per-square-meter or per-hectare rate.',
      '- You may also mention a standard rate per unit area when useful, but you must calculate and state the corresponding total for the cultivated area.',
      '- Check the arithmetic before returning the response.',
      '- Use ranges when agricultural conditions can reasonably cause variation.',
      '- Do not invent false precision.',
      '',
      'Irrigation requirements:',
      '- Give a practical irrigation recommendation in both English and Arabic.',
      '- Include an approximate water quantity or water-volume range for the TOTAL cultivated area whenever reasonably possible.',
      '- Express irrigation water using a practical volume unit such as liters or cubic meters.',
      '- State useful timing or frequency whenever reasonably possible, such as every X days, according to crop growth stage, or according to soil moisture.',
      '- Mention the preferred time of day for irrigation when useful, such as early morning or late afternoon.',
      '- Water requirements vary with soil, climate, growth stage, rainfall, and irrigation method. Make this uncertainty clear when relevant.',
      '- If a reliable exact interval cannot be inferred, provide a practical conditional recommendation rather than inventing certainty.',
      '',
      'Fertilization requirements:',
      '- Give a practical fertilization recommendation in both English and Arabic.',
      '- State when fertilization should begin and how it should be repeated or at which crop growth stages it is commonly applied.',
      '- When a generally reasonable nutrient or fertilizer quantity range can be estimated from common agricultural practice, calculate and state an approximate quantity for the TOTAL cultivated area.',
      '- Prefer nutrient-based or clearly identified general fertilizer guidance rather than pretending that all commercial fertilizer products have the same concentration.',
      '- If a specific fertilizer product, formulation, soil-test result, or nutrient concentration is required to calculate a safe exact product dose, explicitly say that the final product amount must be adjusted according to the fertilizer analysis, soil test, and product label.',
      '- Do not invent an exact commercial fertilizer dose when the required product information is unavailable.',
      '',
      'Spraying requirements:',
      '- Give a practical crop spraying and crop-protection recommendation in both English and Arabic.',
      '- Include routine monitoring and explain when spraying may be appropriate rather than recommending unnecessary pesticide use.',
      '- Identify the most relevant common pest or disease targets for this crop when reasonably inferable from general agricultural practice.',
      '- When treatment may be appropriate, recommend a suitable pesticide TYPE and, when reasonably possible, name one or more commonly used ACTIVE INGREDIENT examples appropriate to the stated target problem (for example an insecticide, fungicide, acaricide, or other crop-protection category).',
      '- Never recommend an active ingredient without also stating the pest or disease problem it is intended to target.',
      '- Do not present a pesticide as mandatory preventive treatment when no pest or disease has been identified. Phrase pesticide choices conditionally, such as: if the named pest or disease is detected and treatment is justified, a registered product containing the suggested active ingredient may be considered.',
      '- Prefer active-ingredient names over commercial brand names because registrations and brands vary by country.',
      '- When reasonably possible, provide an approximate spray-solution or carrier-water volume for the TOTAL cultivated area, calculated from a sensible general coverage rate.',
      '- Clearly distinguish spray-solution volume from pesticide product dose.',
      '- Never invent a pesticide active ingredient concentration, pesticide product dose, mixing ratio, restricted-use instruction, pre-harvest interval, or re-entry interval.',
      '- If a pesticide or other crop-protection product is needed, explicitly state that the suggested active ingredient must be legally registered/labeled for BOTH the crop and target problem in the farmer\'s location, and that the official product label determines the exact dose, dilution, protective equipment, re-entry interval, and pre-harvest interval.',
      '- If several pest or disease problems are common, give a concise conditional mapping such as: target problem -> pesticide type/active ingredient example, rather than mixing unrelated pesticides together.',
      '- Prefer integrated pest management: monitoring, sanitation, cultural control, and targeted treatment only when needed.',
      '- Do not claim that routine pesticide spraying is required when no pest or disease problem has been identified.',
      '',
      'Yield and notes requirements:',
      '- Return concise additional crop notes in both English and Arabic.',
      '- Put general care advice that does not belong specifically to irrigation, fertilization, or spraying in notesEn and notesAr, such as sunlight, drainage, temperature, soil condition, and other useful crop-management cautions.',
      '- Estimate a realistic expected TOTAL yield range for the cultivated area provided by the farmer.',
      '- expectedYieldMin and expectedYieldMax must be positive numbers, and expectedYieldMax must be greater than or equal to expectedYieldMin.',
      '- Return yieldUnit as a short unit such as kg or ton, appropriate for the total estimated production.',
      '- yieldConfidence must be exactly one of: LOW, MEDIUM, HIGH.',
      '- Use HIGH only when the crop, crop type, area, and available context are sufficient for a reasonably stable general estimate.',
      '- Use MEDIUM when the estimate is useful but important factors such as cultivar, soil, climate, irrigation system, or planting density are unknown.',
      '- Use LOW when the available information is too limited for more than a rough estimate.',
      '- Treat the yield as an approximate planning estimate, not a guarantee or measured prediction.',
      '',
      'General response requirements:',
      '- The Arabic and English values must have the same meaning and the same quantities.',
      '- Keep each recommendation practical and readable, but include the important quantity, timing, and safety context.',
      '- Do not claim that any recommendation is universally correct.',
      '- Base recommendations and yield estimates on common general agricultural practice.',
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
      '  "fertilizationScheduleAr": "string",',
      '  "sprayingScheduleEn": "string",',
      '  "sprayingScheduleAr": "string",',
      '  "notesEn": "string",',
      '  "notesAr": "string",',
      '  "expectedYieldMin": 0,',
      '  "expectedYieldMax": 0,',
      '  "yieldUnit": "kg",',
      '  "yieldConfidence": "MEDIUM"',
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
          ? 'تم إنشاء اقتراحات الري والتسميد والرش وتقدير الإنتاج بنجاح'
          : 'Irrigation, fertilization, spraying, and yield suggestions generated successfully',
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

    const sprayingScheduleEn =
      this.normalizeString(
        data.sprayingScheduleEn,
      );

    const sprayingScheduleAr =
      this.normalizeString(
        data.sprayingScheduleAr,
      );

    const notesEn =
      this.normalizeString(
        data.notesEn,
      );

    const notesAr =
      this.normalizeString(
        data.notesAr,
      );

    const expectedYieldMin =
      this.normalizeNumber(
        data.expectedYieldMin,
      );

    const expectedYieldMax =
      this.normalizeNumber(
        data.expectedYieldMax,
      );

    const yieldUnit =
      this.normalizeString(
        data.yieldUnit,
      );

    const yieldConfidenceRaw =
      this.normalizeString(
        data.yieldConfidence,
      ).toUpperCase();

    const yieldConfidence =
      yieldConfidenceRaw === 'LOW' ||
      yieldConfidenceRaw === 'MEDIUM' ||
      yieldConfidenceRaw === 'HIGH'
        ? yieldConfidenceRaw
        : '';

    if (
      cropNameEn.length === 0 ||
      cropNameAr.length === 0 ||
      cropTypeEn.length === 0 ||
      cropTypeAr.length === 0 ||
      irrigationScheduleEn.length === 0 ||
      irrigationScheduleAr.length === 0 ||
      fertilizationScheduleEn.length === 0 ||
      fertilizationScheduleAr.length === 0 ||
      sprayingScheduleEn.length === 0 ||
      sprayingScheduleAr.length === 0 ||
      notesEn.length === 0 ||
      notesAr.length === 0 ||
      expectedYieldMin === null ||
      expectedYieldMax === null ||
      expectedYieldMin <= 0 ||
      expectedYieldMax <= 0 ||
      expectedYieldMax < expectedYieldMin ||
      yieldUnit.length === 0 ||
      yieldConfidence.length === 0
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
      sprayingScheduleEn,
      sprayingScheduleAr,
      notesEn,
      notesAr,
      expectedYieldMin,
      expectedYieldMax,
      yieldUnit,
      yieldConfidence:
        yieldConfidence as
          | 'LOW'
          | 'MEDIUM'
          | 'HIGH',
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

  private normalizeNumber(
    value: unknown,
  ): number | null {
    const numericValue =
      typeof value === 'number'
        ? value
        : typeof value === 'string'
          ? Number(value.trim())
          : NaN;

    return Number.isFinite(
      numericValue,
    )
      ? numericValue
      : null;
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