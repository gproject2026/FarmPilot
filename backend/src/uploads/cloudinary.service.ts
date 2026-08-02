import {
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import {
  UploadApiErrorResponse,
  UploadApiResponse,
  v2 as cloudinary,
} from 'cloudinary';

@Injectable()
export class CloudinaryService {
  constructor() {
    const cloudName =
      process.env.CLOUDINARY_CLOUD_NAME;

    const apiKey =
      process.env.CLOUDINARY_API_KEY;

    const apiSecret =
      process.env.CLOUDINARY_API_SECRET;

    if (
      !cloudName ||
      !apiKey ||
      !apiSecret
    ) {
      throw new Error(
        'Cloudinary environment variables are not defined',
      );
    }

    cloudinary.config({
      cloud_name: cloudName,
      api_key: apiKey,
      api_secret: apiSecret,
      secure: true,
    });
  }

  uploadImage(
    file: Express.Multer.File,
    folder = 'farmpilot',
  ): Promise<UploadApiResponse> {
    return new Promise(
      (
        resolve,
        reject,
      ) => {
        const uploadStream =
          cloudinary.uploader.upload_stream(
            {
              folder,
              resource_type: 'image',
            },
            (
              error:
                | UploadApiErrorResponse
                | undefined,
              result:
                | UploadApiResponse
                | undefined,
            ) => {
              if (error || !result) {
                reject(
                  new InternalServerErrorException(
                    error?.message ??
                      'Failed to upload image to Cloudinary',
                  ),
                );

                return;
              }

              resolve(result);
            },
          );

        uploadStream.end(
          file.buffer,
        );
      },
    );
  }
}