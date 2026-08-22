import {
  BadGatewayException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import {
  GoogleGenAI,
  Type,
} from '@google/genai';

export interface PlantDiagnosisResult {
  isPlant: boolean;
  isImageClear: boolean;
  isHealthy: boolean;
  plantName: string;
  diseaseName: string;
  confidence: number;
  severity: string;
  visibleSymptoms: string[];
  description: string;
  causes: string;
  treatment: string;
  prevention: string;
  needsExpertReview: boolean;
}

export interface DiagnosisTranslationResult {
  plantName: string;
  diseaseName: string;
  visibleSymptoms: string[];
  description: string;
  causes: string;
  treatment: string;
  prevention: string;
}

export interface ProductTranslationResult {
  productName: string;
  description: string;
}

export interface ReminderTranslationResult {
  title: string;
  cropName: string;
}

@Injectable()
export class GeminiService {
  private readonly ai: GoogleGenAI;

  private readonly modelName =
    'gemini-3.6-flash';

  constructor() {
    const apiKey =
      process.env.GEMINI_API_KEY;

    if (!apiKey) {
      throw new Error(
        'GEMINI_API_KEY is not defined',
      );
    }

    this.ai = new GoogleGenAI({
      apiKey,
    });
  }

  async generateText(
    prompt: string,
  ): Promise<string> {
    const response =
      await this.ai.models.generateContent({
        model: this.modelName,
        contents: prompt,
      });

    return response.text ?? '';
  }

  async translateProductContent(params: {
    productName: string;
    description: string;
    targetLanguage: 'ar' | 'en';
  }): Promise<ProductTranslationResult> {
    const {
      productName,
      description,
      targetLanguage,
    } = params;

    const targetLanguageName =
      targetLanguage === 'ar'
        ? 'Arabic'
        : 'English';

    const prompt = [
      `Translate the following farm product content into clear, natural ${targetLanguageName}.`,
      'Preserve the original meaning accurately.',
      'Do not add information that was not provided.',
      'Do not invent certifications, health claims, prices, quantities, discounts, origins, or product qualities.',
      'The translated product name should sound natural and suitable for an agricultural marketplace.',
      'The translated description should be clear and suitable for customers.',
      'Keep brand names and proper nouns unchanged when appropriate.',
      `Return all translated text in ${targetLanguageName}.`,
      '',
      `Product name: ${productName}`,
      `Description: ${description}`,
    ].join('\n');

    let responseText:
      | string
      | undefined;

    try {
      const response =
        await this.ai.models.generateContent({
          model: this.modelName,
          contents: prompt,
          config: {
            responseMimeType:
              'application/json',
            responseSchema: {
              type: Type.OBJECT,
              properties: {
                productName: {
                  type: Type.STRING,
                },
                description: {
                  type: Type.STRING,
                },
              },
              required: [
                'productName',
                'description',
              ],
            },
          },
        });

      responseText =
        response.text;
    } catch (error) {
      console.error(
        'Gemini product translation error:',
        error,
      );

      throw new BadGatewayException(
        'Gemini could not translate the product content',
      );
    }

    if (!responseText) {
      throw new InternalServerErrorException(
        'Gemini did not return a product translation',
      );
    }

    try {
      const result =
        JSON.parse(
          responseText,
        ) as ProductTranslationResult;

      const translatedName =
        result.productName
          ?.toString()
          .trim();

      const translatedDescription =
        result.description
          ?.toString()
          .trim();

      if (
        !translatedName ||
        translatedName.length === 0
      ) {
        throw new Error(
          'Invalid translated product name',
        );
      }

      return {
        productName:
          translatedName,
        description:
          translatedDescription ?? '',
      };
    } catch {
      throw new InternalServerErrorException(
        'Gemini returned an invalid product translation response',
      );
    }
  }

  async translateReminderContent(params: {
    title: string;
    cropName?: string;
    targetLanguage: 'ar' | 'en';
  }): Promise<ReminderTranslationResult> {
    const {
      title,
      cropName,
      targetLanguage,
    } = params;

    const targetLanguageName =
      targetLanguage === 'ar'
        ? 'Arabic'
        : 'English';

    const prompt = [
      `Translate the following farm reminder content into clear, natural ${targetLanguageName}.`,
      'Preserve the original meaning accurately.',
      'Do not add information that was not provided.',
      'Keep the reminder title short and natural.',
      'Translate the crop name naturally when it has a common equivalent.',
      'Keep scientific names, codes, and proper nouns unchanged when appropriate.',
      `Return all translated text in ${targetLanguageName}.`,
      '',
      `Reminder title: ${title}`,
      `Crop name: ${cropName?.trim() || ''}`,
    ].join('\n');

    let responseText:
      | string
      | undefined;

    try {
      const response =
        await this.ai.models.generateContent({
          model: this.modelName,
          contents: prompt,
          config: {
            responseMimeType:
              'application/json',
            responseSchema: {
              type: Type.OBJECT,
              properties: {
                title: {
                  type: Type.STRING,
                },
                cropName: {
                  type: Type.STRING,
                },
              },
              required: [
                'title',
                'cropName',
              ],
            },
          },
        });

      responseText =
        response.text;
    } catch (error) {
      console.error(
        'Gemini reminder translation error:',
        error,
      );

      throw new BadGatewayException(
        'Gemini could not translate the reminder content',
      );
    }

    if (!responseText) {
      throw new InternalServerErrorException(
        'Gemini did not return a reminder translation',
      );
    }

    try {
      const result =
        JSON.parse(
          responseText,
        ) as ReminderTranslationResult;

      const translatedTitle =
        result.title
          ?.toString()
          .trim();

      const translatedCropName =
        result.cropName
          ?.toString()
          .trim();

      if (
        !translatedTitle ||
        translatedTitle.length === 0
      ) {
        throw new Error(
          'Invalid translated reminder title',
        );
      }

      return {
        title:
          translatedTitle,
        cropName:
          translatedCropName ?? '',
      };
    } catch {
      throw new InternalServerErrorException(
        'Gemini returned an invalid reminder translation response',
      );
    }
  }

  async translateDiagnosisToArabic(
    params: {
      plantName: string;
      diseaseName: string;
      visibleSymptoms: string[];
      description: string;
      causes: string;
      treatment: string;
      prevention: string;
    },
  ): Promise<DiagnosisTranslationResult> {
    const {
      plantName,
      diseaseName,
      visibleSymptoms,
      description,
      causes,
      treatment,
      prevention,
    } = params;

    const prompt = [
      'Translate the following plant diagnosis content into clear, natural Arabic.',
      'Do not add new medical or agricultural information.',
      'Preserve the original meaning accurately.',
      'Use simple Arabic suitable for farmers and general users.',
      'Keep scientific names unchanged if present.',
      'Do not translate percentages, IDs, or technical codes.',
      '',
      `Plant name: ${plantName}`,
      `Disease name: ${diseaseName}`,
      `Visible symptoms: ${visibleSymptoms.join(' | ')}`,
      `Description: ${description}`,
      `Possible causes: ${causes}`,
      `Recommended treatment: ${treatment}`,
      `Prevention: ${prevention}`,
    ].join('\n');

    let responseText:
      | string
      | undefined;

    try {
      const response =
        await this.ai.models.generateContent({
          model: this.modelName,
          contents: prompt,
          config: {
            responseMimeType:
              'application/json',
            responseSchema: {
              type: Type.OBJECT,
              properties: {
                plantName: {
                  type: Type.STRING,
                },
                diseaseName: {
                  type: Type.STRING,
                },
                visibleSymptoms: {
                  type: Type.ARRAY,
                  items: {
                    type: Type.STRING,
                  },
                },
                description: {
                  type: Type.STRING,
                },
                causes: {
                  type: Type.STRING,
                },
                treatment: {
                  type: Type.STRING,
                },
                prevention: {
                  type: Type.STRING,
                },
              },
              required: [
                'plantName',
                'diseaseName',
                'visibleSymptoms',
                'description',
                'causes',
                'treatment',
                'prevention',
              ],
            },
          },
        });

      responseText =
        response.text;
    } catch (error) {
      console.error(
        'Gemini diagnosis translation error:',
        error,
      );

      throw new BadGatewayException(
        'Gemini could not translate the diagnosis',
      );
    }

    if (!responseText) {
      throw new InternalServerErrorException(
        'Gemini did not return a translation result',
      );
    }

    try {
      const result =
        JSON.parse(
          responseText,
        ) as DiagnosisTranslationResult;

      result.visibleSymptoms =
        Array.isArray(
          result.visibleSymptoms,
        )
          ? result.visibleSymptoms
          : [];

      return result;
    } catch {
      throw new InternalServerErrorException(
        'Gemini returned an invalid translation response',
      );
    }
  }

  async analyzePlantImage(params: {
    imageUrl: string;
    plantName?: string;
    symptoms?: string;
  }): Promise<PlantDiagnosisResult> {
    const {
      imageUrl,
      plantName,
      symptoms,
    } = params;

    let imageResponse: Response;

    try {
      imageResponse =
        await fetch(
          imageUrl,
        );
    } catch {
      throw new BadGatewayException(
        'Failed to download the plant image',
      );
    }

    if (!imageResponse.ok) {
      throw new BadGatewayException(
        'Failed to download the plant image',
      );
    }

    const contentType =
      imageResponse.headers.get(
        'content-type',
      ) ?? 'image/jpeg';

    if (
      !contentType.startsWith(
        'image/',
      )
    ) {
      throw new BadGatewayException(
        'The provided URL does not contain a valid image',
      );
    }

    const imageBuffer =
      Buffer.from(
        await imageResponse.arrayBuffer(),
      );

    const imageBase64 =
      imageBuffer.toString(
        'base64',
      );

    const prompt = [
      'Analyze the uploaded image as a plant health specialist.',
      'Determine whether the image contains a plant.',
      'Determine whether the image is clear enough for a preliminary visual assessment.',
      'If the plant appears healthy, do not invent a disease.',
      'If the image does not contain a plant, return isPlant as false.',
      'If the image is unclear, return isImageClear as false.',
      'If a disease is possible, provide only a preliminary visual assessment.',
      'Do not claim laboratory certainty.',
      `Provided plant name: ${
        plantName?.trim() ||
        'Not provided'
      }`,
      `Farmer reported symptoms: ${
        symptoms?.trim() ||
        'Not provided'
      }`,
      'The confidence value must be between 0 and 100.',
      'Severity must be one of: none, low, moderate, high, unknown.',
      'Set needsExpertReview to true when confidence is low, the image is unclear, the symptoms appear severe, or chemical treatment may be required.',
      'Treatment must prioritize safe agricultural practices.',
      'Recommend consultation with an agricultural specialist before using hazardous chemicals.',
      'Return concise but useful information.',
    ].join('\n');

    let responseText:
      | string
      | undefined;

    try {
      const response =
        await this.ai.models.generateContent({
          model: this.modelName,
          contents: [
            {
              text: prompt,
            },
            {
              inlineData: {
                mimeType:
                  contentType,
                data:
                  imageBase64,
              },
            },
          ],
          config: {
            responseMimeType:
              'application/json',
            responseSchema: {
              type: Type.OBJECT,
              properties: {
                isPlant: {
                  type: Type.BOOLEAN,
                },
                isImageClear: {
                  type: Type.BOOLEAN,
                },
                isHealthy: {
                  type: Type.BOOLEAN,
                },
                plantName: {
                  type: Type.STRING,
                },
                diseaseName: {
                  type: Type.STRING,
                },
                confidence: {
                  type: Type.NUMBER,
                },
                severity: {
                  type: Type.STRING,
                  enum: [
                    'none',
                    'low',
                    'moderate',
                    'high',
                    'unknown',
                  ],
                },
                visibleSymptoms: {
                  type: Type.ARRAY,
                  items: {
                    type: Type.STRING,
                  },
                },
                description: {
                  type: Type.STRING,
                },
                causes: {
                  type: Type.STRING,
                },
                treatment: {
                  type: Type.STRING,
                },
                prevention: {
                  type: Type.STRING,
                },
                needsExpertReview: {
                  type: Type.BOOLEAN,
                },
              },
              required: [
                'isPlant',
                'isImageClear',
                'isHealthy',
                'plantName',
                'diseaseName',
                'confidence',
                'severity',
                'visibleSymptoms',
                'description',
                'causes',
                'treatment',
                'prevention',
                'needsExpertReview',
              ],
            },
          },
        });

      responseText =
        response.text;
    } catch (error) {
      console.error(
        'Gemini plant analysis error:',
        error,
      );

      throw new BadGatewayException(
        'Gemini could not analyze the plant image',
      );
    }

    if (!responseText) {
      throw new InternalServerErrorException(
        'Gemini did not return a diagnosis result',
      );
    }

    try {
      const result =
        JSON.parse(
          responseText,
        ) as PlantDiagnosisResult;

      result.confidence =
        Math.max(
          0,
          Math.min(
            100,
            Number(
              result.confidence,
            ) || 0,
          ),
        );

      result.visibleSymptoms =
        Array.isArray(
          result.visibleSymptoms,
        )
          ? result.visibleSymptoms
          : [];

      return result;
    } catch {
      throw new InternalServerErrorException(
        'Gemini returned an invalid diagnosis response',
      );
    }
  }
}